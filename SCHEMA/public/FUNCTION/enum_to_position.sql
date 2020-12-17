CREATE OR REPLACE FUNCTION public.enum_to_position(anyenum) RETURNS integer
    LANGUAGE sql STABLE STRICT
    AS $_$
select enumpos::integer from (
	select row_number() over (order by enumsortorder) as enumpos,
		enumsortorder,
        enumlabel
	from pg_catalog.pg_enum
	where enumtypid = pg_typeof($1)
) enum_ordering
where enumlabel = ($1::text);
$_$;

ALTER FUNCTION public.enum_to_position(anyenum) OWNER TO postgres;
