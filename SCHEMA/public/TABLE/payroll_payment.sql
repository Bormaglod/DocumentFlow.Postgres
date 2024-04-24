CREATE TABLE public.payroll_payment (
	date_operation date NOT NULL,
	transaction_amount numeric(15,2) NOT NULL,
	payment_number character varying(15)
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.payroll_payment ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.payroll_payment ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.payroll_payment ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.payroll_payment ALTER COLUMN owner_id SET NOT NULL;

ALTER TABLE ONLY public.payroll_payment ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.payroll_payment ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.payroll_payment OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.payroll_payment TO users;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.payroll_payment TO payroll_accountant;

COMMENT ON TABLE public.payroll_payment IS 'Выплата заработной платы';

COMMENT ON COLUMN public.payroll_payment.owner_id IS 'Платёжная ведомость';

COMMENT ON COLUMN public.payroll_payment.date_operation IS 'Дата операции';

COMMENT ON COLUMN public.payroll_payment.transaction_amount IS 'Сумма платежа';

COMMENT ON COLUMN public.payroll_payment.payment_number IS 'Номер платежного поручения или расходного/приходного ордера';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_payroll_payment_doc_number ON public.payroll_payment USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER payroll_payment_ad
	AFTER DELETE ON public.payroll_payment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER payroll_payment_aiu
	AFTER INSERT OR UPDATE ON public.payroll_payment
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER payroll_payment_au_0
	AFTER UPDATE ON public.payroll_payment
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.payroll_payment_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER payroll_payment_au_1
	AFTER UPDATE ON public.payroll_payment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER payroll_payment_bi
	BEFORE INSERT ON public.payroll_payment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER payroll_payment_bu
	BEFORE UPDATE ON public.payroll_payment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.payroll_payment
	ADD CONSTRAINT fk_payroll_payment_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payroll_payment
	ADD CONSTRAINT fk_payroll_payment_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payroll_payment
	ADD CONSTRAINT fk_payroll_payment_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payroll_payment
	ADD CONSTRAINT fl_payroll_payment_payroll FOREIGN KEY (owner_id) REFERENCES public.payroll(id) ON UPDATE CASCADE ON DELETE RESTRICT;

--------------------------------------------------------------------------------

ALTER TABLE public.payroll_payment
	ADD CONSTRAINT pk_payroll_payment_id PRIMARY KEY (id);
