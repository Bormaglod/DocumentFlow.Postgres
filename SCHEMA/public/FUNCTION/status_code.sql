CREATE OR REPLACE FUNCTION public.status_code(code_value character varying) RETURNS integer
    LANGUAGE sql
    AS $$
	select id from status where code = code_value;
$$;

ALTER FUNCTION public.status_code(code_value character varying) OWNER TO postgres;
