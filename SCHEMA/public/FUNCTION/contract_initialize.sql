CREATE OR REPLACE FUNCTION public.contract_initialize() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.organization_id is null) then 
		new.organization_id = (select id from organization where default_org);
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.contract_initialize() OWNER TO postgres;
