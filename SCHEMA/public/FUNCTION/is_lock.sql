CREATE OR REPLACE FUNCTION public.is_lock(doc_id uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
	return exists(select * from system_process where id = doc_id and sysop = 'lock'::system_operation);
end;
$$;

ALTER FUNCTION public.is_lock(doc_id uuid) OWNER TO postgres;
