CREATE TABLE public.invoice (
	contractor_id uuid,
	invoice_number character varying(20),
	invoice_date date,
	contract_id uuid
)
INHERITS (public.document);

ALTER TABLE ONLY public.invoice ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.invoice OWNER TO postgres;

GRANT ALL ON TABLE public.invoice TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.invoice TO users;

COMMENT ON TABLE public.invoice IS 'Товарная накладная (полученная или выданная)';

COMMENT ON COLUMN public.invoice.invoice_number IS 'Номер счёт-фактуры';

COMMENT ON COLUMN public.invoice.invoice_date IS 'Дата счёт-фактуры';

--------------------------------------------------------------------------------

ALTER TABLE public.invoice
	ADD CONSTRAINT pk_invoice_id PRIMARY KEY (id);
