CREATE OR REPLACE FUNCTION public.update_invoice_sales() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	is_tax boolean;
begin
	select tax_payer into is_tax from contractor where id = new.contractor_id;
	if (not is_tax) then
		new.invoice_number = null;
		new.invoice_date = null;
	end if;
	return new;
end;
$$;

ALTER FUNCTION public.update_invoice_sales() OWNER TO postgres;
