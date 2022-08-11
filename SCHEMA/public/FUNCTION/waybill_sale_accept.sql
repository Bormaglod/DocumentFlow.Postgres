CREATE OR REPLACE FUNCTION public.waybill_sale_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	products price_data;
	contractor_debt numeric;
begin
	if (new.carried_out) then
		for products in
			select reference_id as id, tableoid::regclass as table_name, amount, product_cost 
				from waybill_sale_price
				where owner_id = new.id
		loop
			call balance_product_expense(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, products);
		end loop;

		select sum(full_cost) into contractor_debt from waybill_sale_price where owner_id = new.id;
		call contractor_debt_increase(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, new.contractor_id, new.contract_id, contractor_debt);
	else
		delete from balance_material where owner_id = new.id;
		delete from balance_goods where owner_id = new.id;
		delete from balance_contractor where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.waybill_sale_accept() OWNER TO postgres;
