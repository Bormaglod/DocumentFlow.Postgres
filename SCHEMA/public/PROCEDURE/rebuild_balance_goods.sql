CREATE OR REPLACE PROCEDURE public.rebuild_balance_goods(goods_id uuid, relevance_date timestamp with time zone)
    LANGUAGE plpgsql
    AS $$
begin

end;
$$;

ALTER PROCEDURE public.rebuild_balance_goods(goods_id uuid, relevance_date timestamp with time zone) OWNER TO postgres;

COMMENT ON PROCEDURE public.rebuild_balance_goods(goods_id uuid, relevance_date timestamp with time zone) IS 'Пересчитывает сумму остатка товаров
- goods_id - идентификатор товара, по которому было внесено изменение в таблицу остатков
- relevance_date - дата изменения, после которой надо сделать пересчет';
