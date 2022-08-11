CREATE OR REPLACE FUNCTION public.production_order_mark() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	update production_lot set deleted = true where owner_id = new.id;
	return new;
end;
$$;

ALTER FUNCTION public.production_order_mark() OWNER TO postgres;
