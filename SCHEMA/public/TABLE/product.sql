CREATE TABLE public.product (
	price numeric(15,2),
	vat public.tax_vat,
	measurement_id uuid,
	weight numeric(15,3),
	doc_name character varying(255)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.product ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.product ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.product ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.product OWNER TO postgres;

GRANT SELECT ON TABLE public.product TO users;
GRANT SELECT ON TABLE public.product TO managers;

COMMENT ON TABLE public.product IS 'Общий список материалов, товаров, изделий';

COMMENT ON COLUMN public.product.price IS 'Цена без НДС';

COMMENT ON COLUMN public.product.vat IS 'Ставка НДС';

COMMENT ON COLUMN public.product.measurement_id IS 'Единица измерения';

COMMENT ON COLUMN public.product.weight IS 'Вес';

COMMENT ON COLUMN public.product.doc_name IS 'Наименование используемое в документах';

--------------------------------------------------------------------------------

ALTER TABLE public.product
	ADD CONSTRAINT pk_product_id PRIMARY KEY (id);
