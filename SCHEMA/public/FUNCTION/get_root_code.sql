CREATE OR REPLACE FUNCTION public.get_root_code(object_id uuid) RETURNS character varying
    LANGUAGE sql
    AS $$
	with recursive r as
	(
		select id, parent_id, code from goods where id = object_id
			union
		select p.id, p.parent_id, p.code from goods p join r on (r.parent_id = p.id)
	)
	select code from r where parent_id is null
$$;

ALTER FUNCTION public.get_root_code(object_id uuid) OWNER TO postgres;
