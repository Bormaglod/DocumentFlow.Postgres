CREATE TABLE public.report_card (
	billing_year integer NOT NULL,
	billing_month smallint NOT NULL
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.report_card ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.report_card ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.report_card ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.report_card ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.report_card ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.report_card OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.report_card TO payroll_accountant;

COMMENT ON TABLE public.report_card IS 'Табель';

COMMENT ON COLUMN public.report_card.billing_year IS 'Расчётный год';

COMMENT ON COLUMN public.report_card.billing_month IS 'Расчётный месяц';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_report_card_doc_number ON public.report_card USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER report_card_ad
	AFTER DELETE ON public.report_card
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER report_card_aiu_0
	AFTER INSERT OR UPDATE ON public.report_card
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER report_card_au_1
	AFTER UPDATE ON public.report_card
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER report_card_bi
	BEFORE INSERT ON public.report_card
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER report_card_bu
	BEFORE UPDATE ON public.report_card
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.report_card
	ADD CONSTRAINT fk_report_card_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.report_card
	ADD CONSTRAINT fk_report_card_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.report_card
	ADD CONSTRAINT fk_report_card_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.report_card
	ADD CONSTRAINT pk_report_card_id PRIMARY KEY (id);
