CREATE OR REPLACE FUNCTION public.document_initialize() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
	user_id uuid;
    parent_table varchar;
	state_starting_id smallint;
begin
	select id into user_id from user_alias where pg_name = session_user;

	new.user_created_id = user_id;
	new.date_created = current_timestamp;

	new.user_updated_id = user_id;
	new.date_updated = current_timestamp;
    
	parent_table = get_info_table(TG_TABLE_NAME::varchar);

	if (parent_table = 'directory') then
		new.code = coalesce(new.code, '');
		if (new.code = '') then
			new.code = '_' || nextval('directory_code_seq');
			new.code = substring(TG_TABLE_NAME from 1 for 20 - char_length(new.code)) || new.code;
		end if;
    end if;

	if (parent_table = 'base_document') then
		new.document_date = coalesce(new.document_date, current_timestamp);

		if (new.document_number is null) then
			execute 'select max(document_number) + 1 from ' || quote_ident(TG_TABLE_NAME::varchar) || ' where extract(year from document_date) = $1'
				into new.document_number
				using extract(year from new.document_date);
		
			new.document_number = coalesce(new.document_number, '1');
		end if;
	
		if (TG_TABLE_NAME::varchar not like 'balance%') then
			new.carried_out = false;
		end if;
	
		select id into new.organization_id from organization where default_org = true limit 1;
	
		select
			ss.starting_id
		into state_starting_id
		from schema_states ss
			join document_type dt on dt.id = ss.document_type_id
		where 
			dt.code = TG_TABLE_NAME::varchar;
		
		if (found) then
			new.state_id := state_starting_id;
		end if;
	end if;

	return new;
end;
$_$;

ALTER FUNCTION public.document_initialize() OWNER TO postgres;
