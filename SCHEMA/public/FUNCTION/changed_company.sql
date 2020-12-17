CREATE OR REPLACE FUNCTION public.changed_company() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	code numeric;
begin
	if (new.status_id = 1001) then
		code = coalesce(new.inn, 0);  
		if ((code > 0) and (not contractor_test_inn(code))) then
			raise exception 'Некорректное значение ИНН';
		end if;

		code = coalesce(new.okpo, 0);
		if ((code > 0) and (not contractor_test_okpo(code))) then
			raise exception 'Некорректное значение ОКПО';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_company() OWNER TO postgres;
