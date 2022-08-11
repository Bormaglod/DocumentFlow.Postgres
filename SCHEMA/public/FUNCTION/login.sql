CREATE OR REPLACE FUNCTION public.login() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	delete from system_process;
end;
$$;

ALTER FUNCTION public.login() OWNER TO postgres;
