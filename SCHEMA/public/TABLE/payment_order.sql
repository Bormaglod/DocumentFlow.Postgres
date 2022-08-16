CREATE TABLE public.payment_order (
	contractor_id uuid,
	date_operation date,
	transaction_amount numeric(15,2),
	direction public.payment_direction NOT NULL,
	payment_number character varying(15)
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.payment_order ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.payment_order ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.payment_order ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.payment_order ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.payment_order OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.payment_order TO users;

COMMENT ON COLUMN public.payment_order.payment_number IS 'Номер платежного поручения или расходного/приходного ордера';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_payment_order_doc_number ON public.payment_order USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER payment_order_ad
	AFTER DELETE ON public.payment_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER payment_order_aiu
	AFTER INSERT OR UPDATE ON public.payment_order
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER payment_order_bi
	BEFORE INSERT ON public.payment_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER payment_order_bu
	BEFORE UPDATE ON public.payment_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER payment_order_au_0
	AFTER UPDATE ON public.payment_order
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.payment_order_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER payment_order_au_1
	AFTER UPDATE ON public.payment_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT pk_payment_order_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
