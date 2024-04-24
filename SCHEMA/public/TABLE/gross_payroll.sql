CREATE TABLE public.gross_payroll (
	billing_year integer NOT NULL,
	billing_month smallint NOT NULL
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.gross_payroll ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.gross_payroll ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.gross_payroll ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.gross_payroll ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.gross_payroll ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.gross_payroll OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.gross_payroll TO payroll_accountant;

COMMENT ON TABLE public.gross_payroll IS 'Начисленная заработная плата';

COMMENT ON COLUMN public.gross_payroll.billing_year IS 'Расчётный год';

COMMENT ON COLUMN public.gross_payroll.billing_month IS 'Расчётный месяц';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_gross_payroll_doc_number ON public.gross_payroll USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER gross_payroll_ad
	AFTER DELETE ON public.gross_payroll
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER gross_payroll_aiu_0
	AFTER INSERT OR UPDATE ON public.gross_payroll
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER gross_payroll_au_0
	AFTER UPDATE ON public.gross_payroll
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.gross_payroll_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER gross_payroll_au_1
	AFTER UPDATE ON public.gross_payroll
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER gross_payroll_bi
	BEFORE INSERT ON public.gross_payroll
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER gross_payroll_bu
	BEFORE UPDATE ON public.gross_payroll
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.gross_payroll
	ADD CONSTRAINT fk_gross_payroll_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.gross_payroll
	ADD CONSTRAINT fk_gross_payroll_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.gross_payroll
	ADD CONSTRAINT fk_gross_payroll_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.gross_payroll
	ADD CONSTRAINT pk_gross_payroll_id PRIMARY KEY (id);
