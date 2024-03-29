CREATE OR REPLACE FUNCTION public.balance_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	folder boolean;
begin
	select is_folder into folder from directory where id = new.reference_id;
	if (folder) then
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'reference_id не должен быть папкой.');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.balance_checking() OWNER TO postgres;
