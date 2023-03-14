CREATE OR REPLACE FUNCTION public.waybill_sale_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	products price_data;
	contractor_debt numeric;
	prods numeric;
begin
	if (new.carried_out) then
		prods := 0;
		for products in
			select reference_id as id, tableoid::regclass as table_name, amount, product_cost
				from waybill_sale_price
				where owner_id = new.id
		loop
			call balance_product_expense(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, products);
		end loop;

		select sum(full_cost) into contractor_debt from waybill_sale_price where owner_id = new.id;
		call contractor_debt_increase(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, new.contractor_id, new.contract_id, contractor_debt);
	
		-- ДЗСтп
		if (new.contractor_id = '5a5778be-f5ae-4761-a7c5-b64c13d88078') then
			select sum(wsp.amount)
				into prods
				from waybill_sale_price wsp
					join goods g on g.id = wsp.reference_id
				where wsp.owner_id = new.id and not g.is_service;
			if (prods > 0 and new.document_date >= '01.01.2023') then
				-- если количество проданых изделий ДЗСтп больше 0, выплатим премию Кравчуку по 5 руб. за изделие
				call contractor_debt_reduce(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, 'ce88fa42-1128-4e16-90a7-a19ee18e596c', '8a222918-8da9-4305-b153-667d60436bd6', prods * 5);
			end if;
		end if;
	else
		delete from balance_material where owner_id = new.id;
		delete from balance_goods where owner_id = new.id;
		delete from balance_contractor where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.waybill_sale_accept() OWNER TO postgres;
