CREATE TABLE public.payroll (
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.payroll ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.payroll ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.payroll ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.payroll ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.payroll ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.payroll OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.payroll TO payroll_accountant;

COMMENT ON TABLE public.payroll IS 'Платежная ведомость';

COMMENT ON COLUMN public.payroll.owner_id IS 'Начисление заработной платы';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_payroll_doc_number ON public.payroll USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER payroll_ad
	AFTER DELETE ON public.payroll
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER payroll_aiu
	AFTER INSERT OR UPDATE ON public.payroll
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER payroll_au_0
	AFTER UPDATE ON public.payroll
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.payroll_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER payroll_au_1
	AFTER UPDATE ON public.payroll
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER payroll_bi
	BEFORE INSERT ON public.payroll
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER payroll_bu
	BEFORE UPDATE ON public.payroll
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.payroll
	ADD CONSTRAINT fk_payroll_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payroll
	ADD CONSTRAINT fk_payroll_gross_payroll FOREIGN KEY (owner_id) REFERENCES public.gross_payroll(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payroll
	ADD CONSTRAINT fk_payroll_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payroll
	ADD CONSTRAINT fk_payroll_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payroll
	ADD CONSTRAINT pk_payroll_id PRIMARY KEY (id);
