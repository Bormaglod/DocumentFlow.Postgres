CREATE OR REPLACE FUNCTION public.waybill_receipt_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
	prices price_data;
	contractor_debt numeric;
begin
	if (new.carried_out) then
		for prices in
			execute 'select reference_id as id, ''material'', amount, product_cost from ' || TG_TABLE_NAME::varchar || '_price where owner_id = $1'
				using new.id
		loop
			call balance_product_receipt(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, prices);
		end loop;
	
		execute 'select sum(full_cost) from ' || TG_TABLE_NAME::varchar || '_price where owner_id = $1'
			into contractor_debt
			using new.id;
		call contractor_debt_reduce(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, new.contractor_id, new.contract_id, contractor_debt);
	else
		delete from balance_material where owner_id = new.id;
		delete from balance_contractor where owner_id = new.id;
	end if;

	return new;
end;
$_$;

ALTER FUNCTION public.waybill_receipt_accept() OWNER TO postgres;
