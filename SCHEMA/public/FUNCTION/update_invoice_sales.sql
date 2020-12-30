CREATE OR REPLACE FUNCTION public.update_invoice_sales() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	is_tax boolean;
begin
	if (new.contract_id is not null) then
		select tax_payer into is_tax from contract where id = new.contract_id;
	end if;

	is_tax = coalesce(is_tax, false);
	if (not is_tax) then
		new.invoice_number = null;
		new.invoice_date = null;
	end if;
	return new;
end;
$$;

ALTER FUNCTION public.update_invoice_sales() OWNER TO postgres;
