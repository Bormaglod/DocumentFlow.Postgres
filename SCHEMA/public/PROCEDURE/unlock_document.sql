CREATE OR REPLACE PROCEDURE public.unlock_document(doc_id uuid)
    LANGUAGE sql
    AS $$
	delete from system_process where id = doc_id;
$$;

ALTER PROCEDURE public.unlock_document(doc_id uuid) OWNER TO postgres;
