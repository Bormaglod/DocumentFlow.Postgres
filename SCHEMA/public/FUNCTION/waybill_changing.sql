CREATE OR REPLACE FUNCTION public.waybill_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.upd) then
		new.invoice_number := new.waybill_number;
		new.invoice_date := new.waybill_date;
	else
		if (new.invoice_number is null) then
			new.invoice_date := null;
		end if;
	end if;
	return new;
end;
$$;

ALTER FUNCTION public.waybill_changing() OWNER TO postgres;
