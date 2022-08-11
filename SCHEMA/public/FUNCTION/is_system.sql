CREATE OR REPLACE FUNCTION public.is_system(doc_id uuid, system_value public.system_operation) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
	return exists(select * from system_process where id = doc_id and sysop = system_value);
end;
$$;

ALTER FUNCTION public.is_system(doc_id uuid, system_value public.system_operation) OWNER TO postgres;
