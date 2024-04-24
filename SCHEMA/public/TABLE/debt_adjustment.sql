CREATE TABLE public.debt_adjustment (
	contractor_id uuid,
	document_debt_id uuid,
	document_credit_id uuid,
	transaction_amount numeric(15,2)
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.debt_adjustment ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.debt_adjustment ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.debt_adjustment ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.debt_adjustment ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.debt_adjustment ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.debt_adjustment OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.debt_adjustment TO users;

COMMENT ON TABLE public.debt_adjustment IS 'Корректировка зодлженности поставщику';

COMMENT ON COLUMN public.debt_adjustment.contractor_id IS 'Контрагент';

COMMENT ON COLUMN public.debt_adjustment.document_debt_id IS 'Документ поставки, по которому остался долг контрагента';

COMMENT ON COLUMN public.debt_adjustment.document_credit_id IS 'Документ поставки, по которому остался долг организации';

COMMENT ON COLUMN public.debt_adjustment.transaction_amount IS 'Сумма операции';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_debt_adjustment_doc_number ON public.debt_adjustment USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER debt_adjustment_ad
	AFTER DELETE ON public.debt_adjustment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER debt_adjustment_aiu
	AFTER INSERT OR UPDATE ON public.debt_adjustment
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER debt_adjustment_au_0
	AFTER UPDATE ON public.debt_adjustment
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.debt_adjustment_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER debt_adjustment_au_1
	AFTER UPDATE ON public.debt_adjustment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER debt_adjustment_bi
	BEFORE INSERT ON public.debt_adjustment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER debt_adjustment_bu
	BEFORE UPDATE ON public.debt_adjustment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.debt_adjustment
	ADD CONSTRAINT fk_debt_adjustment_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE RESTRICT;

--------------------------------------------------------------------------------

ALTER TABLE public.debt_adjustment
	ADD CONSTRAINT fk_debt_adjustment_credit FOREIGN KEY (document_credit_id) REFERENCES public.waybill_receipt(id) ON UPDATE CASCADE ON DELETE RESTRICT;

--------------------------------------------------------------------------------

ALTER TABLE public.debt_adjustment
	ADD CONSTRAINT fk_debt_adjustment_debt FOREIGN KEY (document_debt_id) REFERENCES public.waybill_receipt(id) ON UPDATE CASCADE ON DELETE RESTRICT;

--------------------------------------------------------------------------------

ALTER TABLE public.debt_adjustment
	ADD CONSTRAINT pk_debt_adjustment_id PRIMARY KEY (id);
