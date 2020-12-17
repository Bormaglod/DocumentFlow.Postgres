CREATE OR REPLACE FUNCTION public.delete_balance_contractor(document_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	update balance_contractor set status_id = 1011 where owner_id = document_id; 
	delete from balance_contractor where owner_id = document_id;
end;
$$;

ALTER FUNCTION public.delete_balance_contractor(document_id uuid) OWNER TO postgres;
