CREATE OR REPLACE FUNCTION public.return_materials_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	prices price_data;
	ms record;
	wids record;
begin
	for ms in
		select rmr.material_id, rmr.quantity, m.item_name as material_name
			from return_materials_rows rmr
				join material m on m.id = rmr.material_id
			where rmr.owner_id = new.id
	loop
		prices.id = ms.material_id;
		prices.table_name = 'material';
		prices.amount = ms.quantity;
		
		if (new.carried_out) then
			call balance_product_expense(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, prices);
		
			for wids in
				select wpp.id, wpp.price, wpp.amount - wpp.written_off as remaining
					from waybill_processing_price wpp
						join waybill_processing wp on wp.id = wpp.owner_id 
					where wp.owner_id = new.owner_id and wpp.reference_id = ms.material_id and wpp.written_off < wpp.amount 
					order by wp.document_date
			loop
				if (ms.quantity > wids.remaining) then
					ms.quantity := ms.quantity - wids.remaining;
					update waybill_processing_price
						set written_off = amount
						where id = wids.id;
					call contractor_debt_increase(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, new.contractor_id, new.contract_id, wids.price * wids.remaining);
				else
					update waybill_processing_price
						set written_off = written_off + ms.quantity
						where id = wids.id;
					call contractor_debt_increase(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, new.contractor_id, new.contract_id, wids.price * ms.quantity);
					
					ms.quantity := 0;
				
					exit;
				end if;
			
				if (ms.quantity > 0) then
					raise 'Не удалось списать % ед. материала %. Операция не выполнена.', ms.quantity, ms.material_name;
				end if;
			end loop;
		else 
			for wids in
				select wpp.id, wpp.written_off
					from waybill_processing_price wpp
						join waybill_processing wp on wp.id = wpp.owner_id 
					where wp.owner_id = new.owner_id and wpp.reference_id = ms.material_id and wpp.written_off > 0 
					order by wp.document_date desc
			loop 
				if (ms.quantity > wids.written_off) then
					ms.quantity := ms.quantity - wids.written_off;
					update waybill_processing_price
						set written_off = 0
						where id = wids.id;
				else
					update waybill_processing_price
						set written_off = written_off - ms.quantity
						where id = wids.id;
					
					ms.quantity := 0;
				
					exit;
				end if;
			end loop;

			if (ms.quantity > 0) then
				raise 'Не удалось восстановить % ед. материала %. Операция не выполнена.', ms.quantity, ms.material_name;
			end if;
		
			delete from balance_material where owner_id = new.id;
			delete from balance_contractor where owner_id = new.id;
		end if;
	end loop;
	
	return new;
end;
$$;

ALTER FUNCTION public.return_materials_accept() OWNER TO postgres;
