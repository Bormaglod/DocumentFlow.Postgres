CREATE TABLE public.waybill_sale_price_goods (
)
INHERITS (public.waybill_sale_price);

ALTER TABLE ONLY public.waybill_sale_price_goods ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price_goods ALTER COLUMN full_cost SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price_goods ALTER COLUMN id SET DEFAULT nextval('public.product_price_id_seq'::regclass);

ALTER TABLE ONLY public.waybill_sale_price_goods ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price_goods ALTER COLUMN product_cost SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price_goods ALTER COLUMN tax SET DEFAULT 20;

ALTER TABLE ONLY public.waybill_sale_price_goods ALTER COLUMN tax_value SET DEFAULT 0;

ALTER TABLE public.waybill_sale_price_goods OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.waybill_sale_price_goods TO users;

COMMENT ON COLUMN public.waybill_sale_price_goods.amount IS 'Количество';

COMMENT ON COLUMN public.waybill_sale_price_goods.full_cost IS 'Всего с НДС';

COMMENT ON COLUMN public.waybill_sale_price_goods.owner_id IS 'Ссылка на документ';

COMMENT ON COLUMN public.waybill_sale_price_goods.price IS 'Цена без НДС';

COMMENT ON COLUMN public.waybill_sale_price_goods.product_cost IS 'Стоимость товара без НДС';

COMMENT ON COLUMN public.waybill_sale_price_goods.reference_id IS 'Ссылка на товар';

COMMENT ON COLUMN public.waybill_sale_price_goods.tax IS 'Ставка НДС';

COMMENT ON COLUMN public.waybill_sale_price_goods.tax_value IS 'Сумма НДС';

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale_price_goods
	ADD CONSTRAINT pk_waybill_sale_price_goods_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale_price_goods
	ADD CONSTRAINT fk_waybill_sale_price_goods_owner FOREIGN KEY (owner_id) REFERENCES public.waybill_sale(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale_price_goods
	ADD CONSTRAINT fk_waybill_sale_price_goods_ref FOREIGN KEY (reference_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale_price_goods
	ADD CONSTRAINT fk_waybill_sale_price_goods_lot FOREIGN KEY (lot_id) REFERENCES public.production_lot(id) ON UPDATE CASCADE ON DELETE SET NULL;
