CREATE OR REPLACE FUNCTION public.waybill_sale_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	wsp record;
	products price_data;
	contractor_debt numeric;
	prods numeric;
	dzstp_pay numeric;
	lot_info record;
	lot_sold numeric;
	finished numeric;
	goods_type varchar;
begin
	if (new.carried_out) then
		-- уменьшим остаток изделий и материалов
		for wsp in
			select sp.reference_id as id, sp.tableoid::regclass as table_name, sp.amount, sp.product_cost, sp.lot_id, p.item_name
				from waybill_sale_price sp
					join product p on p.id = sp.reference_id
				where sp.owner_id = new.id
		loop
			products.id := wsp.id;
			products.table_name := wsp.table_name;
			products.amount := wsp.amount;
			products.product_cost := wsp.product_cost;
			call balance_product_expense(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, products);
		
			if (wsp.lot_id is not null) then
				select g.id as goods_id, g.is_service, pl.quantity, pl.document_number 
					into lot_info
					from production_lot pl 
						join calculation c on c.id = pl.calculation_id
						join goods g on g.id = c.owner_id
					where pl.id = wsp.lot_id;
				
				if (lot_info.goods_id != wsp.id) then
					if (lot_info.is_service) then
						goods_type := 'Услуга';
					else
						goods_type := 'Изделие';
					end if;
				
					raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, goods_type || ' ' || wsp.item_name || ' отсутствует в партии № ' || lot_info.document_number);
				end if;
			
				-- количество отгруженных изделий из партии
				select sum(quantity) into lot_sold from lot_sale where lot_id = wsp.lot_id;
				lot_sold := coalesce(lot_sold, 0);
			
				-- если в накладной указана услуга, то в качестве количества изготовленных изделий
				-- будет выступать количество единиц из партии
				if (lot_info.is_service) then
					finished := lot_info.quantity; 
				else
					-- количество изготовленных изделий в партии
					select sum(quantity) into finished from finished_goods where owner_id = wsp.lot_id;
					finished := coalesce(finished, 0);		
				end if;
			
				if (wsp.amount > finished - lot_sold) then
					raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Количество изделий ' || wsp.item_name || ' превышает остаток в партии (' || wsp.amount || ' > ' || finished - lot_sold || ')');
				end if;
			
				insert into lot_sale (waybill_sale_id, lot_id, quantity) values (new.id, wsp.lot_id, wsp.amount);
			end if;
		end loop;

		-- сумма отгрузки
		select sum(full_cost) into contractor_debt from waybill_sale_price where owner_id = new.id;
	
		-- увеличим долг контрагента на сумму отгрузки
		call contractor_debt_increase(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, new.contractor_id, new.contract_id, contractor_debt);
	
		-- если контрагент - ДЗСтп
		if (new.contractor_id = '5a5778be-f5ae-4761-a7c5-b64c13d88078') then
			prods := 0;
			select sum(sp.amount)
				into prods
				from waybill_sale_price sp
					join goods g on g.id = sp.reference_id
				where sp.owner_id = new.id and not g.is_service;
			if (prods > 0) then
				if (new.document_date >= '10.06.2022') then
					dzstp_pay = 5;
				else
					dzstp_pay = 2;
				end if;
			
				-- если количество проданых изделий ДЗСтп больше 0, выплатим премию Кравчуку по 2 или 5 руб. за изделие (зависит от периода вырлаты)
				call contractor_debt_reduce(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, 'ce88fa42-1128-4e16-90a7-a19ee18e596c', '8a222918-8da9-4305-b153-667d60436bd6', prods * 5);
			end if;
		end if;
	else
		delete from balance_material where owner_id = new.id;
		delete from balance_goods where owner_id = new.id;
		delete from balance_contractor where owner_id = new.id;
		delete from lot_sale where waybill_sale_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.waybill_sale_accept() OWNER TO postgres;
