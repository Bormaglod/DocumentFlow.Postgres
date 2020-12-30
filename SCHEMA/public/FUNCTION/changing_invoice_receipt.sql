CREATE OR REPLACE FUNCTION public.changing_invoice_receipt() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	is_tax boolean;
begin
	-- СОСТАВЛЕН или ИЗМЕНЯЕТСЯ => КОРРЕКТЕН
	if (old.status_id in (1000, 1004) and new.status_id = 1001) then 
    	if (new.contract_id is not null) then
			select tax_payer into is_tax from contract where id = new.contract_id;
			if (not is_tax) then
				new.invoice_number = null;
				new.invoice_date = null;
			end if;
        end if;
	
		if (new.receipt_date is null) then
			new.receipt_date = new.doc_date;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_invoice_receipt() OWNER TO postgres;

COMMENT ON FUNCTION public.changing_invoice_receipt() IS 'Поступление (акты / накладные) - ИНИЦИАЛИЗАЦИЯ';
