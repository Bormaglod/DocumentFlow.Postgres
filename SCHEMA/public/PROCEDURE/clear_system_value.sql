CREATE OR REPLACE PROCEDURE public.clear_system_value(doc_id uuid)
    LANGUAGE sql
    AS $$
	delete from system_process where id = doc_id;
$$;

ALTER PROCEDURE public.clear_system_value(doc_id uuid) OWNER TO postgres;
