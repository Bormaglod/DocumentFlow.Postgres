CREATE TABLE public.purchase_request_price (
)
INHERITS (public.product_price);

ALTER TABLE ONLY public.purchase_request_price ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.purchase_request_price ALTER COLUMN full_cost SET DEFAULT 0;

ALTER TABLE ONLY public.purchase_request_price ALTER COLUMN id SET DEFAULT nextval('public.product_price_id_seq'::regclass);

ALTER TABLE ONLY public.purchase_request_price ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE ONLY public.purchase_request_price ALTER COLUMN product_cost SET DEFAULT 0;

ALTER TABLE ONLY public.purchase_request_price ALTER COLUMN tax SET DEFAULT 20;

ALTER TABLE ONLY public.purchase_request_price ALTER COLUMN tax_value SET DEFAULT 0;

ALTER TABLE public.purchase_request_price OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.purchase_request_price TO users;

COMMENT ON TABLE public.purchase_request_price IS 'Детализация заявки на закупку материалов';

COMMENT ON COLUMN public.purchase_request_price.amount IS 'Количество';

COMMENT ON COLUMN public.purchase_request_price.full_cost IS 'Всего с НДС';

COMMENT ON COLUMN public.purchase_request_price.owner_id IS 'Идентификатор заказа на закупку';

COMMENT ON COLUMN public.purchase_request_price.price IS 'Цена без НДС';

COMMENT ON COLUMN public.purchase_request_price.product_cost IS 'Стоимость товара без НДС';

COMMENT ON COLUMN public.purchase_request_price.reference_id IS 'Идентификатор заказанного иатериала';

COMMENT ON COLUMN public.purchase_request_price.tax IS 'Ставка НДС';

COMMENT ON COLUMN public.purchase_request_price.tax_value IS 'Сумма НДС';

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request_price
	ADD CONSTRAINT pk_purchase_request_price_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request_price
	ADD CONSTRAINT fk_purchase_request_price_material FOREIGN KEY (reference_id) REFERENCES public.material(id) ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request_price
	ADD CONSTRAINT fk_purchase_request_price_owner FOREIGN KEY (owner_id) REFERENCES public.purchase_request(id) ON UPDATE CASCADE ON DELETE CASCADE;
