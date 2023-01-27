CREATE OR REPLACE FUNCTION public.company_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	code numeric;
	root uuid;
begin
	code := coalesce(new.inn, 0);  
	if ((code > 0) and (not contractor_test_inn(code))) then
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Некорректное значение ИНН.');
	end if;

	code := coalesce(new.okpo, 0);
	if ((code > 0) and (not contractor_test_okpo(code))) then
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Некорректное значение ОКПО.');
	end if;

	if (TG_TABLE_NAME = 'contractor') then
		if (new.parent_id is null) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Выберите группу. Контрагент должен быть или в группе "Юридические лица", или в группе "Физические лица".');
		end if;
	
		with recursive r as
		(
			select id, parent_id from contractor where id = new.id
			union all 
			select c.id, c.parent_id from contractor c join r on r.parent_id = c.id
		)
		select id into root from r where parent_id is null;
	
		-- группа "Юридические лица"
		if (root = 'aee39994-7bfe-46c0-828b-ac6296103cd1') then
			if (new.subject != 'legal entity'::subjects_civil_low) then
				raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Контрагент находится в группе "Юридические лица". Поле "Субъект гражданского права" должно быть установлено в "Юридическое лицо".');
			end if;
		-- группа "Физические лица"
		elseif (root = 'a9799032-2c6a-46da-ab8a-cf6423e3beb6') then
			if (new.subject != 'person'::subjects_civil_low) then
				raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Контрагент находится в группе "Физические лица". Поле "Субъект гражданского права" должно быть установлено в "Физическое лицо".');
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.company_checking() OWNER TO postgres;
