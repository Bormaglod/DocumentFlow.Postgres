CREATE OR REPLACE FUNCTION public.changing_person() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.status_id = 1001) then
		if (new.surname is null) then
			raise 'Укажите фамилию!';
		end if;
	
		if (new.first_name is null) then
			raise 'Укажите фамилию!';
		end if;
	
		new.name = concat(initcap(new.surname), ' ', substr(new.first_name, 1, 1), '.');
		if (new.middle_name is not null) then
			new.name = concat(new.name, ' ', substr(new.middle_name, 1, 1), '.');
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_person() OWNER TO postgres;
