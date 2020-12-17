CREATE OR REPLACE FUNCTION public.get_uuid(kind_code character varying) RETURNS uuid
    LANGUAGE sql IMMUTABLE
    AS $$
select id from entity_kind where code = kind_code;
$$;

ALTER FUNCTION public.get_uuid(kind_code character varying) OWNER TO postgres;
