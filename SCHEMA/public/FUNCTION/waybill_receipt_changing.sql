CREATE OR REPLACE FUNCTION public.waybill_receipt_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.upd) then
		new.invoice_number = new.waybill_number;
		new.invoice_date = new.waybill_date;
	end if;
	return new;
end;
$$;

ALTER FUNCTION public.waybill_receipt_changing() OWNER TO postgres;
