CREATE OR REPLACE FUNCTION public.person_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.surname is null) then
		-- если не указана фамилия, то возможны 2 варианта:
		-- 1. Имя
		new.item_name = initcap(new.first_name);
	
		-- 2. Имя Отчество
		if (new.middle_name is not null) then
			new.item_name = new.item_name || ' ' || initcap(new.middle_name);
		end if;
	else
		-- если фамилия указана, то возможны 3 варианта:
		-- 1. Фамилия
		new.item_name = new.surname;
		if (new.first_name is not null) then
			if (new.middle_name is null) then
				-- 2. Фамилия Имя
				new.item_name = initcap(new.item_name) || ' ' || initcap(new.first_name);
			else
				-- 3. Фамилия И. О.
				new.item_name = initcap(new.item_name) || ' ' || upper(substring(new.first_name from 1 for 1)) || '.' || ' ' || upper(substring(new.middle_name from 1 for 1)) || '.';
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.person_changing() OWNER TO postgres;
