CREATE OR REPLACE FUNCTION public.get_balance_product_info(product_id uuid, relevance_date timestamp with time zone, OUT quantity numeric, OUT price numeric) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	select coalesce(sum(operation_summa * sign(amount)), 0) as operation_summa, coalesce(sum(amount), 0) as amount
		into price, quantity
		from balance_product
		where
			reference_id = product_id and
			document_date < relevance_date;

end;
$$;

ALTER FUNCTION public.get_balance_product_info(product_id uuid, relevance_date timestamp with time zone, OUT quantity numeric, OUT price numeric) OWNER TO postgres;
