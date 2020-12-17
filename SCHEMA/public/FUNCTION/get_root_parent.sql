CREATE OR REPLACE FUNCTION public.get_root_parent(table_name character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare
	parent_table varchar;
begin
	loop
		parent_table = null;
		select pg_class.relname
			into parent_table
			from pg_catalog.pg_inherits
				join pg_catalog.pg_class on (pg_inherits.inhparent = pg_class.oid)
			where
				inhrelid = table_name::regclass;
		table_name = parent_table;
		exit when parent_table is null or parent_table = 'directory' or parent_table = 'document';
	end loop;

	return parent_table; 
end;
$$;

ALTER FUNCTION public.get_root_parent(table_name character varying) OWNER TO postgres;
