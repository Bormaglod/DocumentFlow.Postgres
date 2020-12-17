CREATE OR REPLACE FUNCTION public.document_updating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	user_id uuid;
	rkind record;
	parent_table varchar;
begin
	select id into user_id from user_alias where pg_name = session_user;
    
	new.user_updated_id = user_id;
	new.date_updated = current_timestamp;
    
	if (old.status_id != new.status_id) then
    	insert into history (reference_id, from_status_id, to_status_id, user_id)
			values (new.id, old.status_id, new.status_id, user_id);
	end if;
   
	return new;
end;
$$;

ALTER FUNCTION public.document_updating() OWNER TO postgres;
