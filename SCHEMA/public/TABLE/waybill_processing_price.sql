CREATE TABLE public.waybill_processing_price (
	written_off numeric(12,3) DEFAULT 0 NOT NULL
)
INHERITS (public.product_price);

ALTER TABLE ONLY public.waybill_processing_price ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_processing_price ALTER COLUMN full_cost SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_processing_price ALTER COLUMN id SET DEFAULT nextval('public.product_price_id_seq'::regclass);

ALTER TABLE ONLY public.waybill_processing_price ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_processing_price ALTER COLUMN product_cost SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_processing_price ALTER COLUMN tax SET DEFAULT 20;

ALTER TABLE ONLY public.waybill_processing_price ALTER COLUMN tax_value SET DEFAULT 0;

ALTER TABLE public.waybill_processing_price OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.waybill_processing_price TO users;

COMMENT ON COLUMN public.waybill_processing_price.amount IS 'Количество';

COMMENT ON COLUMN public.waybill_processing_price.full_cost IS 'Всего с НДС';

COMMENT ON COLUMN public.waybill_processing_price.owner_id IS 'Ссылка на документ';

COMMENT ON COLUMN public.waybill_processing_price.price IS 'Цена без НДС';

COMMENT ON COLUMN public.waybill_processing_price.product_cost IS 'Стоимость товара без НДС';

COMMENT ON COLUMN public.waybill_processing_price.reference_id IS 'Ссылка на материал';

COMMENT ON COLUMN public.waybill_processing_price.tax IS 'Ставка НДС';

COMMENT ON COLUMN public.waybill_processing_price.tax_value IS 'Сумма НДС';

COMMENT ON COLUMN public.waybill_processing_price.written_off IS 'Списано материала';

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing_price
	ADD CONSTRAINT pk_waybill_processing_price_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing_price
	ADD CONSTRAINT fk_waybill_processing_price_owner FOREIGN KEY (owner_id) REFERENCES public.waybill_processing(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing_price
	ADD CONSTRAINT fk_waybill_processing_price_ref FOREIGN KEY (reference_id) REFERENCES public.material(id) ON UPDATE CASCADE;
