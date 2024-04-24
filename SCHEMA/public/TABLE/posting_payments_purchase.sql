CREATE TABLE public.posting_payments_purchase (
)
INHERITS (public.posting_payments);

ALTER TABLE ONLY public.posting_payments_purchase ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_purchase ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_purchase ALTER COLUMN document_id SET NOT NULL;

ALTER TABLE ONLY public.posting_payments_purchase ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.posting_payments_purchase ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_purchase ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE ONLY public.posting_payments_purchase ALTER COLUMN transaction_amount SET NOT NULL;

ALTER TABLE public.posting_payments_purchase OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.posting_payments_purchase TO users;

COMMENT ON TABLE public.posting_payments_purchase IS 'Разнесение платежей по заявкам на покупку (счетам на олату)';

COMMENT ON COLUMN public.posting_payments_purchase.document_id IS 'Заявка на покупку';

COMMENT ON COLUMN public.posting_payments_purchase.owner_id IS 'Платёжный ордер';

COMMENT ON COLUMN public.posting_payments_purchase.transaction_amount IS 'Сумма операции';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_posting_payments_purchase_doc_number ON public.posting_payments_purchase USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_purchase_ad
	AFTER DELETE ON public.posting_payments_purchase
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER posting_payments_purchase_aiu
	AFTER INSERT OR UPDATE ON public.posting_payments_purchase
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_purchase_au_0
	AFTER UPDATE ON public.posting_payments_purchase
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.posting_payments_purchase_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_purchase_au_1
	AFTER UPDATE ON public.posting_payments_purchase
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_purchase_bi
	BEFORE INSERT ON public.posting_payments_purchase
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_purchase_bu
	BEFORE UPDATE ON public.posting_payments_purchase
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_purchase
	ADD CONSTRAINT chk_posting_payments_purchase_transaction CHECK ((transaction_amount > (0)::numeric));

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_purchase
	ADD CONSTRAINT fk_posting_payments_purchase FOREIGN KEY (document_id) REFERENCES public.purchase_request(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_purchase
	ADD CONSTRAINT fk_posting_payments_purchase_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_purchase
	ADD CONSTRAINT fk_posting_payments_purchase_order FOREIGN KEY (owner_id) REFERENCES public.payment_order(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_purchase
	ADD CONSTRAINT fk_posting_payments_purchase_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_purchase
	ADD CONSTRAINT fk_posting_payments_purchase_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_purchase
	ADD CONSTRAINT pk_posting_payments_purchase_id PRIMARY KEY (id);
