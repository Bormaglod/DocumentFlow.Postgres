CREATE TABLE public.posting_payments_receipt (
)
INHERITS (public.posting_payments);

ALTER TABLE ONLY public.posting_payments_receipt ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_receipt ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_receipt ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.posting_payments_receipt ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.posting_payments_receipt OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.posting_payments_receipt TO users;

COMMENT ON TABLE public.posting_payments_receipt IS 'Разнесение платежей по накладным на поступление материалов';

COMMENT ON COLUMN public.posting_payments_receipt.document_id IS 'Поступление (акты / накладные)';

COMMENT ON COLUMN public.posting_payments_receipt.owner_id IS 'Платёжный ордер';

COMMENT ON COLUMN public.posting_payments_receipt.transaction_amount IS 'Сумма операции';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_posting_payments_receipt_doc_number ON public.posting_payments_receipt USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_receipt_ad
	AFTER DELETE ON public.posting_payments_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER posting_payments_receipt_aiu
	AFTER INSERT OR UPDATE ON public.posting_payments_receipt
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_receipt_au_0
	AFTER UPDATE ON public.posting_payments_receipt
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.posting_payments_receipt_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_receipt_bi
	BEFORE INSERT ON public.posting_payments_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_receipt_bu
	BEFORE UPDATE ON public.posting_payments_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_receipt_au_1
	AFTER UPDATE ON public.posting_payments_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_receipt
	ADD CONSTRAINT chk_posting_payments_receipt_transaction CHECK ((transaction_amount > (0)::numeric));

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_receipt
	ADD CONSTRAINT pk_posting_payments_receipt_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_receipt
	ADD CONSTRAINT fk_posting_payments_receipt FOREIGN KEY (document_id) REFERENCES public.waybill_receipt(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_receipt
	ADD CONSTRAINT fk_posting_payments_receipt_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_receipt
	ADD CONSTRAINT fk_posting_payments_receipt_order FOREIGN KEY (owner_id) REFERENCES public.payment_order(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_receipt
	ADD CONSTRAINT fk_posting_payments_receipt_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_receipt
	ADD CONSTRAINT fk_posting_payments_receipt_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
