CREATE OR REPLACE FUNCTION public.document_updating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	user_id uuid;
begin
	select id into user_id from user_alias where pg_name = session_user;
    
	new.user_updated_id = user_id;
	new.date_updated = current_timestamp;

	if (get_info_table(TG_TABLE_NAME::varchar) = 'directory') then
		if (new.deleted) then
			update directory set deleted = true where parent_id = new.id;		
		end if;
	else
		if (not is_inherit_of(TG_TABLE_NAME::varchar, 'balance')) then
			if (new.carried_out and old.carried_out) then
				new.re_carried_out = true;
			end if;
		
			if (new.carried_out != old.carried_out) then
				new.re_carried_out = false;				
			end if;
		else
		
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.document_updating() OWNER TO postgres;
