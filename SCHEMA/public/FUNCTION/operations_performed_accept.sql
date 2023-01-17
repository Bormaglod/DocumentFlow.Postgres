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
	prod_started bool;
	state lot_state;
begin
	-- количество изделий в партии
	select po.id as order_id, po.contractor_id, po.contract_id, pl.quantity, pl.calculation_id, g.item_name as goods_name
		into lot_info
		from production_lot pl
			join production_order po on po.id = pl.owner_id 
			join calculation c on c.id = pl.calculation_id 
			join goods g on g.id = c.owner_id
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
			call balance_product_expense(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, prices, giving_material);
		
			-- в этом случае необходимо выбрать все записи переданных материалов в переработку
			-- по данному заказу (количество списанных материалов должно быть меньше переданных в переработку)
			if (giving_material) then
				for wids in
					select
						wp.id,
						wp.contractor_id,
						wpp.amount - coalesce(wpw.written_off, 0) as remaining
					from waybill_processing wp
						join waybill_processing_price wpp on wpp.owner_id = wp.id 
						left join (
							select 
								waybill_processing_id, 
								material_id, 
								sum(amount) as written_off
							from waybill_processing_writeoff
							group by waybill_processing_id, material_id
						) wpw on (wpw.waybill_processing_id = wp.id and wpw.material_id = wpp.reference_id)
					where 
						wp.owner_id = lot_info.order_id and 
						wpp.reference_id = rec.material_id and 
						coalesce(wpw.written_off, 0) < wpp.amount
					order by wp.document_date
				loop
					if (wids.contractor_id != lot_info.contractor_id) then
						raise 'Заказ содержит изделие [%] на изготовление которого был использован материал [%] контрагента [%] который не является заказчиком.',
							lot_info.goods_name,
							wids.material_name,
							wids.contractor_name;
					end if;
				
					raise notice 'Выполнение операции. id = %, remaining = %', wids.id, wids.remaining;
					-- если количество материалов, которое необходимо списать больше, чем возможно указать
					-- в записи о передаче материало в переработку, то запишем туда максимум возможного, а остольное спишем 
					-- в следующей записи
					if (prices.amount > wids.remaining) then
						prices.amount := prices.amount - wids.remaining;
						insert into waybill_processing_writeoff (operation_write_off_id, waybill_processing_id, material_id, amount)
							values (new.id, wids.id, rec.material_id, wids.remaining);
					else
						insert into waybill_processing_writeoff (operation_write_off_id, waybill_processing_id, material_id, amount)
							values (new.id, wids.id, rec.material_id, prices.amount);
						prices.amount := 0;
						exit;
					end if;
				end loop;
			
				if (prices.amount > 0) then
					raise 'Не удалось списать % ед. материала. Операция не выполнена.', prices.amount;
				end if;
			end if;
		end if;
	
		call set_production_lot_state(new.owner_id, 'production'::lot_state);
	else
		if (giving_material) then
			delete from waybill_processing_writeoff where operation_write_off_id = new.id;
		end if;
		
		delete from balance_material where owner_id = new.id;
	
		prod_started := exists(select 1 from operations_performed where owner_id = new.owner_id and carried_out);
		if (prod_started) then
			state := 'production'::lot_state;
		else
			state := 'created'::lot_state;
		end if;
	
		call set_production_lot_state(new.owner_id, state);
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.operations_performed_accept() OWNER TO postgres;
