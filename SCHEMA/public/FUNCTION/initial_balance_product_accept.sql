CREATE OR REPLACE FUNCTION public.initial_balance_product_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	material_info price_data;
begin
	if (new.carried_out) then
		material_info.id = new.reference_id;
		material_info.table_name = TG_TABLE_NAME::varchar;
		material_info.amount = new.amount;
		material_info.product_cost = new.operation_summa;
	
		call balance_product_receipt(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, material_info);
	else
		if (TG_TABLE_NAME = 'initial_balance_material') then
			delete from balance_material where owner_id = new.id;
		elseif (TG_TABLE_NAME = 'initial_balance_goods') then
			delete from balance_goods where owner_id = new.id;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.initial_balance_product_accept() OWNER TO postgres;
