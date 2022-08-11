CREATE OR REPLACE FUNCTION public.person_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.surname is null) then
		if (new.first_name is null) then
			raise 'Укажите имя!';
		end if;
	else
		if (new.first_name is null) then
			-- если имя не указано, то отчество тоже не указывается
			if (new.middle_name is not null) then
				raise 'Укажите имя!';
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.person_checking() OWNER TO postgres;
