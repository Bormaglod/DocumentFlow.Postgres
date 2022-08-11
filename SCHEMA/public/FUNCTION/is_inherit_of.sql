CREATE OR REPLACE FUNCTION public.is_inherit_of(table_name character varying, inherit_table character varying) RETURNS boolean
    LANGUAGE sql
    AS $$
	with recursive cte as
	(
		select inhrelid, inhparent from pg_inherits where inhrelid = table_name::regclass
		union
		select p.inhrelid, p.inhparent from pg_inherits p join cte on (cte.inhparent = p.inhrelid)
	) 
	select count(*) = 1
		from cte
			join pg_class on (cte.inhparent = pg_class.oid)
		where
			pg_class.relname = inherit_table;
$$;

ALTER FUNCTION public.is_inherit_of(table_name character varying, inherit_table character varying) OWNER TO postgres;
