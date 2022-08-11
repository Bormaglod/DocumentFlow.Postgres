CREATE OR REPLACE FUNCTION public.employee_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	person_name varchar;
begin
	if (new.person_id is not null) then 
		select item_name into new.item_name from person where id = new.person_id;
	end if;

	if (new.owner_id is null) then
		if (TG_TABLE_NAME = 'our_employee') then
			select id into new.owner_id from organization where default_org;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.employee_changing() OWNER TO postgres;
