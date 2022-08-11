CREATE TABLE public.waybill_sale_price_material (
)
INHERITS (public.waybill_sale_price);

ALTER TABLE ONLY public.waybill_sale_price_material ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price_material ALTER COLUMN full_cost SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price_material ALTER COLUMN id SET DEFAULT nextval('public.product_price_id_seq'::regclass);

ALTER TABLE ONLY public.waybill_sale_price_material ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price_material ALTER COLUMN product_cost SET DEFAULT 0;

ALTER TABLE ONLY public.waybill_sale_price_material ALTER COLUMN tax SET DEFAULT 20;

ALTER TABLE ONLY public.waybill_sale_price_material ALTER COLUMN tax_value SET DEFAULT 0;

ALTER TABLE public.waybill_sale_price_material OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.waybill_sale_price_material TO users;

COMMENT ON COLUMN public.waybill_sale_price_material.amount IS 'Количество';

COMMENT ON COLUMN public.waybill_sale_price_material.full_cost IS 'Всего с НДС';

COMMENT ON COLUMN public.waybill_sale_price_material.owner_id IS 'Ссылка на документ';

COMMENT ON COLUMN public.waybill_sale_price_material.price IS 'Цена без НДС';

COMMENT ON COLUMN public.waybill_sale_price_material.product_cost IS 'Стоимость материала без НДС';

COMMENT ON COLUMN public.waybill_sale_price_material.reference_id IS 'Ссылка на материал';

COMMENT ON COLUMN public.waybill_sale_price_material.tax IS 'Ставка НДС';

COMMENT ON COLUMN public.waybill_sale_price_material.tax_value IS 'Сумма НДС';

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale_price_material
	ADD CONSTRAINT pk_waybill_sale_price_material_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale_price_material
	ADD CONSTRAINT fk_waybill_sale_price_material_owner FOREIGN KEY (owner_id) REFERENCES public.waybill_sale(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale_price_material
	ADD CONSTRAINT fk_waybill_sale_price_material_ref FOREIGN KEY (reference_id) REFERENCES public.material(id) ON UPDATE CASCADE;
