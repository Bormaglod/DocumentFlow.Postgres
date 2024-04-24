CREATE TABLE public.posting_payments_balance (
)
INHERITS (public.posting_payments);

ALTER TABLE ONLY public.posting_payments_balance ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_balance ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_balance ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.posting_payments_balance ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments_balance ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.posting_payments_balance OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.posting_payments_balance TO users;

COMMENT ON TABLE public.posting_payments_balance IS 'Разнесение платежей от контрагентов (закрытие начальных остатков)';

COMMENT ON COLUMN public.posting_payments_balance.document_id IS 'Начальный остаток';

COMMENT ON COLUMN public.posting_payments_balance.owner_id IS 'Платёжный ордер';

COMMENT ON COLUMN public.posting_payments_balance.transaction_amount IS 'Сумма операции';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_posting_payments_balance_doc_number ON public.posting_payments_balance USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_balance_ad
	AFTER DELETE ON public.posting_payments_balance
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER posting_payments_balance_aiu
	AFTER INSERT OR UPDATE ON public.posting_payments_balance
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_balance_au_1
	AFTER UPDATE ON public.posting_payments_balance
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_balance_bi
	BEFORE INSERT ON public.posting_payments_balance
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER posting_payments_balance_bu
	BEFORE UPDATE ON public.posting_payments_balance
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_balance
	ADD CONSTRAINT chk_posting_payments_balance_transaction CHECK ((transaction_amount > (0)::numeric));

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_balance
	ADD CONSTRAINT fk_posting_payments_balance FOREIGN KEY (document_id) REFERENCES public.initial_balance_contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_balance
	ADD CONSTRAINT fk_posting_payments_balance_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_balance
	ADD CONSTRAINT fk_posting_payments_balance_order FOREIGN KEY (owner_id) REFERENCES public.payment_order(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_balance
	ADD CONSTRAINT fk_posting_payments_balance_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_balance
	ADD CONSTRAINT fk_posting_payments_balance_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments_balance
	ADD CONSTRAINT pk_posting_payments_balance_id PRIMARY KEY (id);
