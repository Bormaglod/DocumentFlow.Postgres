CREATE OR REPLACE FUNCTION public.operations_performed_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	op_sum integer;
	rec record;
	prices price_data;
	giving_material boolean;
	wids record;
	lot_info record;
begin
	-- количество изделий в партии
	select po.id as order_id, po.contractor_id, po.contract_id, pl.quantity, pl.calculation_id
		into lot_info
		from production_lot pl
			join production_order po on po.id = pl.owner_id 
		where pl.id = new.owner_id;

	-- количество операций и материала необходимых для изготовления указанной партии
	select repeats * lot_info.quantity as op_quantity, material_id, material_amount
		into rec
		from calculation_operation
		where id = new.operation_id and not deleted;
	
	-- материал может быть давальческим
	select is_giving 
		into giving_material
		from calculation_material 
		where owner_id = lot_info.calculation_id and item_id = rec.material_id;
			
	raise notice 'Выполнение операции. Материал давальческий: %', giving_material;

	if (new.carried_out) then
		-- общее количество выполненных операций
		select sum(quantity) 
			into op_sum 
			from operations_performed 
			where owner_id = new.owner_id and carried_out and operation_id = new.operation_id 
			group by owner_id, operation_id;
	
		if (rec.op_quantity < op_sum) then
			raise 'Количество выполненных операций [%] превышает максимально возможное [%].', op_sum, rec.op_quantity;
		end if;
	
		-- если для операции требуется материал, то
		if (rec.material_id is not null) then
			-- он может быть заменен на альтернативный
			if (new.replacing_material_id is not null) then
				rec.material_id = new.replacing_material_id;
			end if;
		
			-- уменьшение остатка использованного материала
			prices.id = rec.material_id;
			prices.table_name = 'material';
			prices.amount = new.quantity * rec.material_amount;
		
			raise notice 'Выполнение операции. Количество операций: %, Количество материала на 1 оп.: %', new.quantity, rec.material_amount;

			-- Расход материала
			call balance_product_expense(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, prices);
		
			-- в этом случае необходимо выбрать все записи переданных материалов в переработку
			-- по данному заказу (количество списанных материалов должно быть меньше переданных в переработку)
			if (giving_material) then
				for wids in
					select wpp.id, wpp.price, wpp.amount - wpp.written_off as remaining
						from waybill_processing_price wpp
							join waybill_processing wp on wp.id = wpp.owner_id 
						where wp.owner_id = lot_info.order_id and wpp.reference_id = rec.material_id and wpp.written_off < wpp.amount 
						order by wp.document_date
				loop 
					raise notice 'Выполнение операции. id = %, price = %, remaining = %', wids.id, wids.price, wids.remaining;
					-- если количество материалов, которое необходимо списать больше, чем возможно указать
					-- в записи о передаче материало в переработку, то запишем туда максимум возможного, а остольное спишем 
					-- в следующей записи
					if (prices.amount > wids.remaining) then
						prices.amount := prices.amount - wids.remaining;
						update waybill_processing_price
							set written_off = amount
							where id = wids.id;
						raise notice 'Выполнение операции. Погашение долга в сумме %', wids.price * wids.remaining;
						call contractor_debt_increase(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, lot_info.contractor_id, lot_info.contract_id, wids.price * wids.remaining);
					else
						update waybill_processing_price
							set written_off = written_off + prices.amount
							where id = wids.id;
						
						raise notice 'Выполнение операции. Погашение долга в сумме %', wids.price * prices.amount;
						call contractor_debt_increase(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, lot_info.contractor_id, lot_info.contract_id, wids.price * prices.amount);
					
						prices.amount := 0;
						exit;
					end if;
				end loop;
			
				if (prices.amount > 0) then
					raise 'Не удалось списать % ед. материала. Операция не выполнена.', prices.amount;
				end if;
			end if;
		end if;
	else
		if (giving_material) then
			prices.amount = new.quantity * rec.material_amount;
		
			for wids in
				select wpp.id, wpp.written_off
					from waybill_processing_price wpp
						join waybill_processing wp on wp.id = wpp.owner_id 
					where wp.owner_id = lot_info.order_id and wpp.reference_id = rec.material_id and wpp.written_off > 0 
					order by wp.document_date desc
			loop 
				if (prices.amount > wids.written_off) then
					prices.amount := prices.amount - wids.written_off;
					update waybill_processing_price
						set written_off = 0
						where id = wids.id;
				else
					update waybill_processing_price
						set written_off = written_off - prices.amount
						where id = wids.id;
					prices.amount := 0;
					exit;
				end if;
			end loop;
			
			if (prices.amount > 0) then
				raise 'Не удалось восстановить % ед. материала. Операция не выполнена.', prices.amount;
			end if;
		end if;
		
		delete from balance_material where owner_id = new.id;
		delete from balance_contractor where owner_id = new.id;
	end if;
	
	return new;
end;
$$;

ALTER FUNCTION public.operations_performed_accept() OWNER TO postgres;
