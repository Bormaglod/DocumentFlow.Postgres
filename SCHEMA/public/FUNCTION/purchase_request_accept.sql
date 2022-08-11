CREATE OR REPLACE FUNCTION public.purchase_request_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	return new;
end;
$$;

ALTER FUNCTION public.purchase_request_accept() OWNER TO postgres;
