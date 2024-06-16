CREATE OR REPLACE FUNCTION public.document_updating() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
	user_id uuid;
	type_id uuid;
begin
	select id into user_id from user_alias where pg_name = session_user;
    
	new.user_updated_id = user_id;
	new.date_updated = current_timestamp;

	if (get_info_table(TG_TABLE_NAME::varchar) = 'directory') then
		if (new.deleted) then
			execute format('update %I set deleted = true where parent_id = $1', TG_TABLE_NAME::varchar) using new.id;
		end if;
	else
		if (old.state_id != new.state_id) then
		
		else
			if (not is_inherit_of(TG_TABLE_NAME::varchar, 'balance')) then
				if (new.carried_out and old.carried_out and not is_system(new.id, 'lock_reaccept'::system_operation)) then
					raise notice 'UPDATING document. setting re_carried flag';
					new.re_carried_out = true;
				end if;
		
				if (new.carried_out != old.carried_out) then
					raise notice 'UPDATING document. canceling re_carried flag';
					new.re_carried_out = false;				
				end if;
			end if;
		end if;
	end if;

	return new;
end;
$_$;

ALTER FUNCTION public.document_updating() OWNER TO postgres;
