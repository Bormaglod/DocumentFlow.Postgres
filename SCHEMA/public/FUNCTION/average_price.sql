CREATE OR REPLACE FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) RETURNS numeric
    LANGUAGE sql
    AS $$
	select avg_price from get_balance_product_info(product_id, relevance_date);
$$;

ALTER FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) OWNER TO postgres;

COMMENT ON FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) IS 'Возвращает среднюю цену материала на указанную дату
- product_id - идентификатор материала
- relevance_date - дата от которой ведется поиск остатков';
