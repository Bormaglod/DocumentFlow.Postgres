CREATE OR REPLACE FUNCTION public.waybill_receipt_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	co boolean;
begin
	if (new.carried_out) then
		if (new.owner_id is not null) then
			select carried_out into co from purchase_request where id = new.owner_id;
			if (not co) then
				raise 'Заявка должна быть проведена';
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.waybill_receipt_checking() OWNER TO postgres;
