CREATE TABLE public.production_order_price (
	complete_status smallint DEFAULT 0,
	calculation_id uuid NOT NULL
)
INHERITS (public.product_price);

ALTER TABLE ONLY public.production_order_price ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.production_order_price ALTER COLUMN full_cost SET DEFAULT 0;

ALTER TABLE ONLY public.production_order_price ALTER COLUMN id SET DEFAULT nextval('public.product_price_id_seq'::regclass);

ALTER TABLE ONLY public.production_order_price ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE ONLY public.production_order_price ALTER COLUMN product_cost SET DEFAULT 0;

ALTER TABLE ONLY public.production_order_price ALTER COLUMN tax SET DEFAULT 20;

ALTER TABLE ONLY public.production_order_price ALTER COLUMN tax_value SET DEFAULT 0;

ALTER TABLE public.production_order_price OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.production_order_price TO users;

COMMENT ON TABLE public.production_order_price IS 'Детализация заказа на изготовление';

COMMENT ON COLUMN public.production_order_price.amount IS 'Количество';

COMMENT ON COLUMN public.production_order_price.full_cost IS 'Всего с НДС';

COMMENT ON COLUMN public.production_order_price.owner_id IS 'Идентификатор заказа на изготовление';

COMMENT ON COLUMN public.production_order_price.price IS 'Цена без НДС';

COMMENT ON COLUMN public.production_order_price.product_cost IS 'Стоимость товара без НДС';

COMMENT ON COLUMN public.production_order_price.reference_id IS 'Идентификатор изделия';

COMMENT ON COLUMN public.production_order_price.tax IS 'Ставка НДС';

COMMENT ON COLUMN public.production_order_price.tax_value IS 'Сумма НДС';

COMMENT ON COLUMN public.production_order_price.complete_status IS 'Процент изготовления';

COMMENT ON COLUMN public.production_order_price.calculation_id IS 'Идентификатор калькуляции используемой для изготовления изделия';

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_price
	ADD CONSTRAINT chk_production_order_price_complete CHECK (((complete_status >= 0) AND (complete_status <= 100)));

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_price
	ADD CONSTRAINT pk_production_order_price_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_price
	ADD CONSTRAINT fk_production_order_price_goods FOREIGN KEY (reference_id) REFERENCES public.goods(id) ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_price
	ADD CONSTRAINT fk_production_order_price_owner FOREIGN KEY (owner_id) REFERENCES public.production_order(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_price
	ADD CONSTRAINT fk_production_order_price_calculation FOREIGN KEY (calculation_id) REFERENCES public.calculation(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_price
	ADD CONSTRAINT unq_production_order_price_calc UNIQUE (owner_id, calculation_id);
