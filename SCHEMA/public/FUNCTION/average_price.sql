CREATE OR REPLACE FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) RETURNS numeric
    LANGUAGE sql
    AS $$
	select coalesce(avg(operation_summa / amount), 0)
		from balance_product
		where
			reference_id = product_id and
			document_date < relevance_date and
			amount > 0;
$$;

ALTER FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) OWNER TO postgres;

COMMENT ON FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) IS 'Возвращает среднюю цену материала на указанную дату
- product_id - идентификатор материала
- relevance_date - дата от которой ведется поиск остатков';
