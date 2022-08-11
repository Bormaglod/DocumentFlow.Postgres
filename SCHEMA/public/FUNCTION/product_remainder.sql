CREATE OR REPLACE FUNCTION public.product_remainder(product_id uuid, actual_date timestamp with time zone) RETURNS numeric
    LANGUAGE sql
    AS $$
	select coalesce(sum(amount), 0)
		from balance_product
		where
			reference_id = product_id and
			document_date <= actual_date;
$$;

ALTER FUNCTION public.product_remainder(product_id uuid, actual_date timestamp with time zone) OWNER TO postgres;

COMMENT ON FUNCTION public.product_remainder(product_id uuid, actual_date timestamp with time zone) IS 'Возвращает остаток материала/товара на указанную дату
- goods_id - идентификатор материала
- actual_date - дата на которую необходимо получить остаток материала';
