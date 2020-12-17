CREATE OR REPLACE FUNCTION public.delete_archive_price(arhive_price_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	update archive_price set status_id = 1011 where id = arhive_price_id;
	delete from archive_price where id = arhive_price_id;
end;
$$;

ALTER FUNCTION public.delete_archive_price(arhive_price_id uuid) OWNER TO postgres;
