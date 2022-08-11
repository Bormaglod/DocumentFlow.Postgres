CREATE TABLE public.waybill_sale_price (
)
INHERITS (public.product_price);

ALTER TABLE ONLY public.waybill_sale_price ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price ALTER COLUMN full_cost SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price ALTER COLUMN id SET DEFAULT nextval('public.product_price_id_seq'::regclass);

ALTER TABLE ONLY public.waybill_sale_price ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price ALTER COLUMN product_cost SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price ALTER COLUMN tax SET DEFAULT 20;

ALTER TABLE ONLY public.waybill_sale_price ALTER COLUMN tax_value SET DEFAULT 0;

ALTER TABLE public.waybill_sale_price OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.waybill_sale_price TO users;

COMMENT ON COLUMN public.waybill_sale_price.amount IS 'Количество';

COMMENT ON COLUMN public.waybill_sale_price.full_cost IS 'Всего с НДС';

COMMENT ON COLUMN public.waybill_sale_price.owner_id IS 'Ссылка на документ';

COMMENT ON COLUMN public.waybill_sale_price.price IS 'Цена без НДС';

COMMENT ON COLUMN public.waybill_sale_price.product_cost IS 'Стоимость товара без НДС';

COMMENT ON COLUMN public.waybill_sale_price.reference_id IS 'Ссылка на товар';

COMMENT ON COLUMN public.waybill_sale_price.tax IS 'Ставка НДС';

COMMENT ON COLUMN public.waybill_sale_price.tax_value IS 'Сумма НДС';

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale_price
	ADD CONSTRAINT pk_waybill_sale_price_id PRIMARY KEY (id);
