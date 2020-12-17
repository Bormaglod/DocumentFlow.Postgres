CREATE OR REPLACE FUNCTION public.root_code_operation(object_id uuid) RETURNS character varying
    LANGUAGE sql
    AS $$
	with recursive r as
	(
		select id, parent_id, code from operation where id = object_id and parent_id is not null
			union
		select p.id, p.parent_id, p.code from operation p join r on (r.parent_id = p.id)
	)
	select code from r where parent_id is null
$$;

ALTER FUNCTION public.root_code_operation(object_id uuid) OWNER TO postgres;
