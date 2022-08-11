CREATE OR REPLACE FUNCTION public.waybill_processing_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	materials price_data;
begin
	if (new.carried_out) then
		for materials in
			select reference_id as id, 'material', amount, product_cost 
				from waybill_processing_price
				where owner_id = new.id
		loop
			call balance_product_receipt(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, materials);
		end loop;
	else
		delete from balance_material where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.waybill_processing_accept() OWNER TO postgres;
