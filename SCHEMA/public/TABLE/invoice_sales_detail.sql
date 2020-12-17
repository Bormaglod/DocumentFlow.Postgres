CREATE TABLE public.invoice_sales_detail (
)
INHERITS (public.goods_price_detail);

ALTER TABLE ONLY public.invoice_sales_detail ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.invoice_sales_detail ALTER COLUMN cost SET DEFAULT 0;

ALTER TABLE ONLY public.invoice_sales_detail ALTER COLUMN cost_with_tax SET DEFAULT 0;

ALTER TABLE ONLY public.invoice_sales_detail ALTER COLUMN id SET DEFAULT nextval('public.goods_price_detail_id_seq'::regclass);

ALTER TABLE ONLY public.invoice_sales_detail ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE ONLY public.invoice_sales_detail ALTER COLUMN tax SET DEFAULT 20;

ALTER TABLE ONLY public.invoice_sales_detail ALTER COLUMN tax_value SET DEFAULT 0;

ALTER TABLE public.invoice_sales_detail OWNER TO postgres;

GRANT ALL ON TABLE public.invoice_sales_detail TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.invoice_sales_detail TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales_detail
	ADD CONSTRAINT fk_invoice_sales_detail_owner FOREIGN KEY (owner_id) REFERENCES public.invoice_sales(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales_detail
	ADD CONSTRAINT fk_invoice_sales_detail_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales_detail
	ADD CONSTRAINT pk_invoice_sales_detail_id PRIMARY KEY (id);
