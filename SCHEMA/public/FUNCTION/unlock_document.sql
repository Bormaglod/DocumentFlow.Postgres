CREATE OR REPLACE FUNCTION public.unlock_document(document_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
declare
	user_id uuid;
begin
	select id into user_id from user_alias where pg_name = session_user;
	update document_info 
		set date_locked = null, 
			user_locked_id = null 
		where 
			id = document_id;
end;
$$;

ALTER FUNCTION public.unlock_document(document_id uuid) OWNER TO postgres;
