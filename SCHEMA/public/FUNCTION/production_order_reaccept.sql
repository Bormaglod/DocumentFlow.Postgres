CREATE OR REPLACE FUNCTION public.production_order_reaccept(document_id uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
	return false;
end;
$$;

ALTER FUNCTION public.production_order_reaccept(document_id uuid) OWNER TO postgres;
