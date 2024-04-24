CREATE TABLE public.posting_payments_sale (
)
INHERITS (public.posting_payments);

ALTER TABLE ONLY public.posting_payments_sale ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_sale ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_sale ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.posting_payments_sale ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_sale ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.posting_payments_sale OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.posting_payments_sale TO users;

COMMENT ON TABLE public.posting_payments_sale IS 'Разнесение платежей от контрагентов за поставленную продукцию';

COMMENT ON COLUMN public.posting_payments_sale.document_id IS 'Реализация';

COMMENT ON COLUMN public.posting_payments_sale.owner_id IS 'Платёжный ордер';

COMMENT ON COLUMN public.posting_payments_sale.transaction_amount IS 'Сумма операции';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_posting_payments_sale_doc_number ON public.posting_payments_sale USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_sale_ad
	AFTER DELETE ON public.posting_payments_sale
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER posting_payments_sale_aiu
	AFTER INSERT OR UPDATE ON public.posting_payments_sale
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_sale_au_0
	AFTER UPDATE ON public.posting_payments_sale
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.posting_payments_sale_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_sale_au_1
	AFTER UPDATE ON public.posting_payments_sale
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_sale_bi
	BEFORE INSERT ON public.posting_payments_sale
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_sale_bu
	BEFORE UPDATE ON public.posting_payments_sale
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_sale
	ADD CONSTRAINT chk_posting_payments_sale_transaction CHECK ((transaction_amount > (0)::numeric));

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_sale
	ADD CONSTRAINT fk_posting_payments_sale FOREIGN KEY (document_id) REFERENCES public.waybill_sale(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_sale
	ADD CONSTRAINT fk_posting_payments_sale_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_sale
	ADD CONSTRAINT fk_posting_payments_sale_order FOREIGN KEY (owner_id) REFERENCES public.payment_order(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_sale
	ADD CONSTRAINT fk_posting_payments_sale_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_sale
	ADD CONSTRAINT fk_posting_payments_sale_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_sale
	ADD CONSTRAINT pk_posting_payments_sale_id PRIMARY KEY (id);
