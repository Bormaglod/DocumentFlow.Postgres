CREATE OR REPLACE FUNCTION public.changed_employee() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	person_name varchar;
begin
	if (new.status_id = 1001) then
		if (new.person_id is null) then 
			raise 'Укажите сотрудника!';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_employee() OWNER TO postgres;
