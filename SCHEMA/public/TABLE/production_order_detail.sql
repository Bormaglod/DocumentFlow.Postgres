CREATE TABLE public.production_order_detail (
	complete_status smallint DEFAULT 0,
	calculation_id uuid
)
INHERITS (public.goods_price_detail);

ALTER TABLE ONLY public.production_order_detail ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.production_order_detail ALTER COLUMN cost SET DEFAULT 0;

ALTER TABLE ONLY public.production_order_detail ALTER COLUMN cost_with_tax SET DEFAULT 0;

ALTER TABLE ONLY public.production_order_detail ALTER COLUMN id SET DEFAULT nextval('public.goods_price_detail_id_seq'::regclass);

ALTER TABLE ONLY public.production_order_detail ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE ONLY public.production_order_detail ALTER COLUMN tax SET DEFAULT 20;

ALTER TABLE ONLY public.production_order_detail ALTER COLUMN tax_value SET DEFAULT 0;

ALTER TABLE public.production_order_detail OWNER TO postgres;

GRANT ALL ON TABLE public.production_order_detail TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.production_order_detail TO users;

COMMENT ON COLUMN public.production_order_detail.amount IS 'Количество';

COMMENT ON COLUMN public.production_order_detail.cost IS 'Сумма';

COMMENT ON COLUMN public.production_order_detail.cost_with_tax IS 'Всего с НДС';

COMMENT ON COLUMN public.production_order_detail.goods_id IS 'Идентификатор изделия';

COMMENT ON COLUMN public.production_order_detail.owner_id IS 'Идентификатор заказа на изготовление';

COMMENT ON COLUMN public.production_order_detail.price IS 'Цена';

COMMENT ON COLUMN public.production_order_detail.tax IS 'Ставка НДС';

COMMENT ON COLUMN public.production_order_detail.tax_value IS 'Сумма НДС';

COMMENT ON COLUMN public.production_order_detail.complete_status IS 'Процент изготовления';

COMMENT ON COLUMN public.production_order_detail.calculation_id IS 'Идентификатор калькуляции используемой для изготовления изделия';

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_detail
	ADD CONSTRAINT fk_production_order_detail_owner FOREIGN KEY (owner_id) REFERENCES public.production_order(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_detail
	ADD CONSTRAINT pk_production_order_detail_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_detail
	ADD CONSTRAINT fk_production_order_detail_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_detail
	ADD CONSTRAINT fk_production_order_detail_calculation FOREIGN KEY (calculation_id) REFERENCES public.calculation(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order_detail
	ADD CONSTRAINT chk_production_order_detail_complete CHECK (((complete_status >= 0) AND (complete_status <= 100)));

COMMENT ON CONSTRAINT chk_production_order_detail_complete ON public.production_order_detail IS 'Процент изготовления должен быть в пределах диапазона от 0 до 100';
