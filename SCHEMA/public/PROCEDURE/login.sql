CREATE OR REPLACE PROCEDURE public.login()
    LANGUAGE plpgsql
    AS $$
begin
	delete from system_process;
end;
$$;

ALTER PROCEDURE public.login() OWNER TO postgres;

--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE public.login(user_id uuid, user_token text)
    LANGUAGE plpgsql
    AS $$
begin
	delete from system_process;
	
	update user_alias set access_token = user_token where id = user_id;
end;
$$;

ALTER PROCEDURE public.login(user_id uuid, user_token text) OWNER TO postgres;
