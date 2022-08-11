CREATE OR REPLACE FUNCTION public.production_lot_mark() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	update operations_performed set deleted = true where owner_id = new.id;
	return new;
end;
$$;

ALTER FUNCTION public.production_lot_mark() OWNER TO postgres;
