CREATE TABLE public.wage1c (
	billing_year integer NOT NULL,
	billing_month smallint NOT NULL
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.wage1c ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.wage1c ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.wage1c ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.wage1c ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.wage1c ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.wage1c OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.wage1c TO payroll_accountant;

COMMENT ON TABLE public.wage1c IS 'Заработная плата начисленная в 1С';

COMMENT ON COLUMN public.wage1c.billing_year IS 'Расчётный год';

COMMENT ON COLUMN public.wage1c.billing_month IS 'Расчётный месяц';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_wage1c_doc_number ON public.wage1c USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER wage1c_ad
	AFTER DELETE ON public.wage1c
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER wage1c_aiu_0
	AFTER INSERT OR UPDATE ON public.wage1c
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER wage1c_au_0
	AFTER UPDATE ON public.wage1c
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.wage1c_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER wage1c_au_1
	AFTER UPDATE ON public.wage1c
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER wage1c_bi
	BEFORE INSERT ON public.wage1c
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER wage1c_bu
	BEFORE UPDATE ON public.wage1c
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.wage1c
	ADD CONSTRAINT fk_wage1c_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.wage1c
	ADD CONSTRAINT fk_wage1c_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.wage1c
	ADD CONSTRAINT fk_wage1c_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.wage1c
	ADD CONSTRAINT pk_wage1c_id PRIMARY KEY (id);
