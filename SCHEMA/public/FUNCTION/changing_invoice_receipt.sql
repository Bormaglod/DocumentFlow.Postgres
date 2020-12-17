CREATE OR REPLACE FUNCTION public.changing_invoice_receipt() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	is_tax boolean;
	count_rows integer;
begin
	-- => КОРРЕКТЕН
	if (new.status_id = 1001) then 
		if (new.contractor_id is null) then
			raise 'Необходимо указать контрагента!';
		end if;
	
		select tax_payer into is_tax from contractor where id = new.contractor_id;
		if (is_tax) then
			if (new.invoice_number is null) then
				raise 'Укажите номер входной счёт-фактуры.';
			end if;
		
			if (new.invoice_date is null) then
				raise 'Укажите дату входной счёт-фактуры.';
			end if;
		else
			new.invoice_number = null;
			new.invoice_date = null;
		end if;
	
		select count(*) into count_rows from invoice_receipt_detail where owner_id = new.id;
		if (count_rows = 0) then
			raise 'Заполните табличную часть!';
		end if;
	
		if (new.receipt_date is null) then
			new.receipt_date = new.doc_date;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_invoice_receipt() OWNER TO postgres;
