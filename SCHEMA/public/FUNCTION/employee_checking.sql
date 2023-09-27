CREATE OR REPLACE FUNCTION public.employee_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.item_name is null) then 
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Укажите сотрудника!');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.employee_checking() OWNER TO postgres;
