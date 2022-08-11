CREATE OR REPLACE FUNCTION public.company_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	code numeric;
begin
	code = coalesce(new.inn, 0);  
	if ((code > 0) and (not contractor_test_inn(code))) then
		raise exception 'Некорректное значение ИНН';
	end if;

	code = coalesce(new.okpo, 0);
	if ((code > 0) and (not contractor_test_okpo(code))) then
		raise exception 'Некорректное значение ОКПО';
	end if;

	if (new.parent_id is null) then
		raise exception 'Выберите группу. Контрагент должен быть или в группе "Юридические лица", или в группе "Физические лица".';
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.company_checking() OWNER TO postgres;
