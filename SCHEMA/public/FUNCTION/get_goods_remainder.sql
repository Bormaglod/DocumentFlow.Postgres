CREATE OR REPLACE FUNCTION public.get_goods_remainder(goods_id uuid, actual_date timestamp with time zone) RETURNS numeric
    LANGUAGE sql
    AS $$
	select coalesce(sum(amount * sign(operation_summa::numeric)), 0)
		from balance_goods
		where
			reference_id = goods_id and
			document_date <= actual_date and 
			status_id in (1110, 1111, 1112);
$$;

ALTER FUNCTION public.get_goods_remainder(goods_id uuid, actual_date timestamp with time zone) OWNER TO postgres;

COMMENT ON FUNCTION public.get_goods_remainder(goods_id uuid, actual_date timestamp with time zone) IS 'Возвращает остаток материала на указанную дату
- goods_id - идентификатор материала
- actual_date - дата на которую необходимо получить остаток материала';

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.get_goods_remainder(goods_id uuid, _contractor_id uuid, actual_date timestamp with time zone) RETURNS numeric
    LANGUAGE sql
    AS $$
	select coalesce(sum(amount), 0)
		from balance_tolling
		where
			reference_id = goods_id and
			document_date <= actual_date and 
			contractor_id = _contractor_id and
			status_id in (1110, 1111, 1112);
$$;

ALTER FUNCTION public.get_goods_remainder(goods_id uuid, _contractor_id uuid, actual_date timestamp with time zone) OWNER TO postgres;
