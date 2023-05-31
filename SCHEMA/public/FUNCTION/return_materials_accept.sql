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
				select 
					wp.id, 
					wpp.amount - coalesce(wpw.written_off, 0) as remaining
				from waybill_processing_price wpp
					join waybill_processing wp on wp.id = wpp.owner_id
					left join (
						select 
							waybill_processing_id, 
							material_id, 
							sum(amount) as written_off
						from waybill_processing_writeoff
						group by waybill_processing_id, material_id
					) wpw on (wpw.waybill_processing_id = wp.id and wpw.material_id = wpp.reference_id)
				where 
					wp.owner_id = new.owner_id and 
					wpp.reference_id = ms.material_id and 
					coalesce(wpw.written_off, 0) < wpp.amount 
				order by wp.document_date
			loop
				if (ms.quantity > wids.remaining) then
					ms.quantity := ms.quantity - wids.remaining;
					insert into waybill_processing_writeoff (operation_write_off_id, waybill_processing_id, material_id, amount, write_off)
						values (new.id, wids.id, ms.material_id, wids.remaining, 'return'::write_off_method);
				else
					insert into waybill_processing_writeoff (operation_write_off_id, waybill_processing_id, material_id, amount, write_off)
						values (new.id, wids.id, ms.material_id, ms.quantity, 'return'::write_off_method);
					ms.quantity := 0;
					exit;
				end if;
			
				if (ms.quantity > 0) then
					raise 'Не удалось списать % ед. материала %. Операция не выполнена.', ms.quantity, ms.material_name;
				end if;
			end loop;
		else 
			delete from waybill_processing_writeoff where operation_write_off_id = new.id;
			delete from balance_material where owner_id = new.id;
		end if;
	end loop;
	
	return new;
end;
$$;

ALTER FUNCTION public.return_materials_accept() OWNER TO postgres;
