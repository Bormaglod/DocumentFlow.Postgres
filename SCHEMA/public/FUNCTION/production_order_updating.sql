CREATE OR REPLACE FUNCTION public.production_order_updating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	return new;
end;
$$;

ALTER FUNCTION public.production_order_updating() OWNER TO postgres;
