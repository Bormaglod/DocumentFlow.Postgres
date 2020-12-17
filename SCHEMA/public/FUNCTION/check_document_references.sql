CREATE OR REPLACE FUNCTION public.check_document_references() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	owner uuid;
begin
	select id into owner from document_info where id = new.owner_id;

	if (owner is null) then
		raise 'Владелец (id = %) не найден.', new.owner_id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.check_document_references() OWNER TO postgres;
