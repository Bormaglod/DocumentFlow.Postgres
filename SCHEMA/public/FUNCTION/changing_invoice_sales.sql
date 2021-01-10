CREATE OR REPLACE FUNCTION public.changing_invoice_sales() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	is_tax boolean;
	all_rows integer;
	tax_rows integer;
	r record;
	rem numeric;
begin
-- => КОРРЕКТЕН
	if (new.status_id = 1001) then 
		if (new.contractor_id is null) then
			raise 'Необходимо указать контрагента!';
		end if;
	
		if (new.contract_id is not null) then
			select tax_payer into is_tax from contract where id = new.contract_id;
			if (is_tax) then
				if (new.invoice_number is null) then
					new.invoice_number = new.doc_number;
				end if;
		
				if (new.invoice_date is null) then
					new.invoice_date = new.doc_date;
				end if;
			end if;
		end if;
	
		select count(*), count(*) filter (where tax > 0) into all_rows, tax_rows from invoice_sales_detail where owner_id = new.id;
		if (all_rows = 0) then
			raise 'Заполните табличную часть!';
		end if;
	
		if (tax_rows > 0 and tax_rows != all_rows) then 
			raise 'Табличная часть содержит номенклатуру с отличающимися значениями ставки НДС!';
		end if;
	
		if (is_tax and tax_rows = 0) then
			raise 'Покупатель является плательщиком НДС. Продукцию надо продавать с НДС!';
		end if;

		if (not is_tax and tax_rows = all_rows) then
			raise 'Покупатель не является плательщиком НДС. Продукцию надо продавать без НДС!';
		end if;
	
		for r in
			select goods_id, amount from invoice_sales_detail where owner_id = new.id
		loop
			rem = get_goods_remainder(r.goods_id, new.doc_date);
			if (rem < r.amount) then
				raise 'На складе недостаточно изделий "%". Требуется %, а в наличии - %', 
					(select name from goods where id = r.goods_id),
					r.amount, 
					rem;
			end if;
		end loop;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_invoice_sales() OWNER TO postgres;
