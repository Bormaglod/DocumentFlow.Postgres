CREATE OR REPLACE FUNCTION public.contract_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.date_end is not null and old.date_end is null) then 
		update contract_application 
			set date_end = new.date_end
			where owner_id = new.id and date_end is null;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.contract_updated() OWNER TO postgres;
