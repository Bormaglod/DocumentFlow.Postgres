CREATE TABLE public.goods_price_detail (
	id bigint DEFAULT nextval('public.goods_price_detail_id_seq'::regclass) NOT NULL,
	owner_id uuid,
	goods_id uuid,
	amount numeric(12,3) DEFAULT 0,
	price money DEFAULT 0,
	cost money DEFAULT 0,
	tax public.tax_nds DEFAULT 20,
	tax_value money DEFAULT 0,
	cost_with_tax money DEFAULT 0
);

ALTER TABLE public.goods_price_detail OWNER TO postgres;

GRANT ALL ON TABLE public.goods_price_detail TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.goods_price_detail TO users;

COMMENT ON COLUMN public.goods_price_detail.amount IS 'Количество';

COMMENT ON COLUMN public.goods_price_detail.price IS 'Цена без НДС';

COMMENT ON COLUMN public.goods_price_detail.cost IS 'Стоимость товара без НДС';

COMMENT ON COLUMN public.goods_price_detail.tax IS 'Ставка НДС';

COMMENT ON COLUMN public.goods_price_detail.tax_value IS 'Сумма НДС';

COMMENT ON COLUMN public.goods_price_detail.cost_with_tax IS 'Всего с НДС';

--------------------------------------------------------------------------------

ALTER TABLE public.goods_price_detail
	ADD CONSTRAINT pk_goods_price_detail_id PRIMARY KEY (id);
