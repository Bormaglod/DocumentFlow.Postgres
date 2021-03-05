CREATE OR REPLACE FUNCTION public.initialize_tolling_material() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	new.operation_summa = 0;
	return new;
end;
$$;

ALTER FUNCTION public.initialize_tolling_material() OWNER TO postgres;
