CREATE OR REPLACE FUNCTION public.get_balance_product_info(product_id uuid, relevance_date timestamp with time zone, OUT quantity numeric, OUT price numeric, OUT avg_price numeric) RETURNS record
    LANGUAGE plpgsql
    AS $$
begin
	select coalesce(sum(operation_summa * sign(amount)), 0) as operation_summa, coalesce(sum(amount), 0) as amount
		into price, quantity
		from balance_product
		where
			reference_id = product_id and
			document_date < relevance_date;
		
	if (quantity = 0) then
		avg_price := 0;
	else
		avg_price := round(price / quantity, 2);
	end if;
end;
$$;

ALTER FUNCTION public.get_balance_product_info(product_id uuid, relevance_date timestamp with time zone, OUT quantity numeric, OUT price numeric, OUT avg_price numeric) OWNER TO postgres;
