CREATE OR REPLACE FUNCTION public.command_initialize() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	new.date_updated = now();
    return new;
end;
$$;

ALTER FUNCTION public.command_initialize() OWNER TO postgres;
