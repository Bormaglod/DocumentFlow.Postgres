CREATE OR REPLACE PROCEDURE public.login()
    LANGUAGE plpgsql
    AS $$
begin
	delete from system_process;
end;
$$;

ALTER PROCEDURE public.login() OWNER TO postgres;
