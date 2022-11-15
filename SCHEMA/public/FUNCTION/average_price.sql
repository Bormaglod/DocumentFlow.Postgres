CREATE OR REPLACE FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
declare
	avg_price numeric;
begin
	select sum(operation_summa * sign(amount)) / sum(amount)
		into avg_price
		from balance_product
		where
			reference_id = product_id and
			document_date < relevance_date
		having sum(amount) != 0;
	
	if (coalesce(avg_price, 0) = 0) then
		select sum(bp.operation_summa) / sum(bp.amount)
			into avg_price
			from balance_product bp
			join document_type dt on dt.id = bp.document_type_id 
			where
				bp.reference_id = product_id and
				bp.document_date <= relevance_date and
				dt.account_avg
			having sum(bp.amount) != 0;
			
		if (coalesce(avg_price, 0) = 0) then
			select coalesce(price, 0) into avg_price from product where id = product_id;
		end if;
	end if;

	return avg_price;
end;
$$;

ALTER FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) OWNER TO postgres;

COMMENT ON FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) IS 'Возвращает среднюю цену материала на указанную дату
- product_id - идентификатор материала
- relevance_date - дата от которой ведется поиск остатков';
