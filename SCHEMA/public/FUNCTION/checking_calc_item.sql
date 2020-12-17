CREATE OR REPLACE FUNCTION public.checking_calc_item() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	calculation_status integer;
begin
	if (new.owner_id is not null) then
		select status_id into calculation_status from calculation where id = new.owner_id;
		if (not calculation_status in (1000, 1004)) then
			if (TG_OP = 'INSERT' or old.owner_id is null) then
				raise 'Калькуляция должна быть в стостянии СОСТАВЛЕН или ИЗМЕНЯЕТСЯ';
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.checking_calc_item() OWNER TO postgres;
