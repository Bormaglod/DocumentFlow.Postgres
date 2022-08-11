CREATE OR REPLACE FUNCTION public.account_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	new.account_value = coalesce(new.account_value, 0);
	return new;
end;
$$;

ALTER FUNCTION public.account_changing() OWNER TO postgres;
