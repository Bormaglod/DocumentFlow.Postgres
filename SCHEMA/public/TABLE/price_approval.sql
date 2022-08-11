CREATE TABLE public.price_approval (
	id bigint DEFAULT nextval('public.price_approval_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	product_id uuid NOT NULL,
	price numeric(15,2) DEFAULT 0 NOT NULL
);

ALTER TABLE public.price_approval OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.price_approval TO users;

COMMENT ON TABLE public.price_approval IS 'Список материалов и изделий из приложения к договору';

COMMENT ON COLUMN public.price_approval.owner_id IS 'Ссылка на приложение к договору';

COMMENT ON COLUMN public.price_approval.product_id IS 'Ссылка на товар (материал или изделие)';

COMMENT ON COLUMN public.price_approval.price IS 'Цена без учёта налогов';

--------------------------------------------------------------------------------

CREATE INDEX idx_price_approval_reference_id ON public.price_approval USING btree (product_id);

--------------------------------------------------------------------------------

ALTER TABLE public.price_approval
	ADD CONSTRAINT pk_price_approval_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.price_approval
	ADD CONSTRAINT fk_price_approval_owner FOREIGN KEY (owner_id) REFERENCES public.contract_application(id) ON UPDATE CASCADE ON DELETE CASCADE;
