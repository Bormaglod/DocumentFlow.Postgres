CREATE OR REPLACE FUNCTION public.bank_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	new.bik = coalesce(new.bik, 0);
	new.account = coalesce(new.account, 0);
	return new;
end;
$$;

ALTER FUNCTION public.bank_changing() OWNER TO postgres;
