CREATE OR REPLACE FUNCTION public.document_initialize() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	user_id uuid;
	rkind record;
    parent_table varchar;
    doc_prefix varchar;
	doc_digits integer;
begin
	select id into user_id from user_alias where pg_name = session_user;

	new.user_created_id = user_id;
	new.date_created = current_timestamp;

	new.user_updated_id = user_id;
	new.date_updated = current_timestamp;
    
	new.entity_kind_id = coalesce(new.entity_kind_id, get_uuid(TG_TABLE_NAME::varchar));

    -- стартовое значение состояния документа указанное в new.entity_kind_id
	select ek.has_group, t.starting_id
		into rkind
		from entity_kind ek
			join transition t on (t.id = ek.transition_id)
		where ek.id = new.entity_kind_id;

	new.status_id = coalesce(new.status_id, rkind.starting_id);
    if (new.status_id != 500 and new.status_id != rkind.starting_id) then
    	new.status_id = rkind.starting_id;
    end if;

	parent_table = get_root_parent(TG_TABLE_NAME::varchar);

	if (parent_table = 'directory') then
		new.code = coalesce(new.code, '');
		if (new.code = '') then
			new.code = '_' || nextval('directory_code_seq');
			new.code = substring(TG_TABLE_NAME from 1 for 20 - char_length(new.code)) || new.code;
		end if;
    end if;

	if (parent_table = 'document') then
		new.doc_date = current_timestamp;
		new.doc_year = extract(year from new.doc_date);
		select max(substring(doc_number from '^\D*(\d+)')::bigint) + 1 into new.doc_number from document where entity_kind_id = new.entity_kind_id and doc_year = new.doc_year;

		new.doc_number = coalesce(new.doc_number, '1');
		
		select id into new.organization_id from organization where default_org = true limit 1;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.document_initialize() OWNER TO postgres;
