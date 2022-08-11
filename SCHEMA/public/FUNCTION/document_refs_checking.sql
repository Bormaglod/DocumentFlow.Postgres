CREATE OR REPLACE FUNCTION public.document_refs_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	doc_owner_id uuid;
begin
	select id into doc_owner_id from document_info where id = new.owner_id;

	if (doc_owner_id is null) then
		raise 'Владелец (id = %) не найден.', new.owner_id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.document_refs_checking() OWNER TO postgres;
