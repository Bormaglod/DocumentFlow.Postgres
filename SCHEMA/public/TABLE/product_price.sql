CREATE TABLE public.product_price (
	id bigint DEFAULT nextval('public.product_price_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	reference_id uuid NOT NULL,
	amount numeric(12,3) DEFAULT 0 NOT NULL,
	price numeric(15,2) DEFAULT 0 NOT NULL,
	product_cost numeric(15,2) DEFAULT 0 NOT NULL,
	tax public.tax_vat DEFAULT 20 NOT NULL,
	tax_value numeric(15,2) DEFAULT 0 NOT NULL,
	full_cost numeric(15,2) DEFAULT 0 NOT NULL
);

ALTER TABLE public.product_price OWNER TO postgres;

GRANT SELECT ON TABLE public.product_price TO users;

COMMENT ON COLUMN public.product_price.owner_id IS 'Ссылка на документ';

COMMENT ON COLUMN public.product_price.reference_id IS 'Ссылка на товар (материал или изделие)';

COMMENT ON COLUMN public.product_price.amount IS 'Количество';

COMMENT ON COLUMN public.product_price.price IS 'Цена без НДС';

COMMENT ON COLUMN public.product_price.product_cost IS 'Стоимость товара без НДС';

COMMENT ON COLUMN public.product_price.tax IS 'Ставка НДС';

COMMENT ON COLUMN public.product_price.tax_value IS 'Сумма НДС';

COMMENT ON COLUMN public.product_price.full_cost IS 'Всего с НДС';

--------------------------------------------------------------------------------

ALTER TABLE public.product_price
	ADD CONSTRAINT pk_product_price_id PRIMARY KEY (id);
