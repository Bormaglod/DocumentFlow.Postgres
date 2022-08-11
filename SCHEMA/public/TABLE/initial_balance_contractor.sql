CREATE TABLE public.initial_balance_contractor (
	contract_id uuid NOT NULL
)
INHERITS (public.initial_balance);

ALTER TABLE ONLY public.initial_balance_contractor ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.initial_balance_contractor ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance_contractor ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance_contractor ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.initial_balance_contractor ALTER COLUMN operation_summa SET DEFAULT 0;

ALTER TABLE ONLY public.initial_balance_contractor ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.initial_balance_contractor OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.initial_balance_contractor TO users;

COMMENT ON COLUMN public.initial_balance_contractor.amount IS 'Число больше 0 определяет увеличение долга контрагента, меньше 0 - уменьшение долга';

COMMENT ON COLUMN public.initial_balance_contractor.document_date IS 'Дата на которую определен остаток';

COMMENT ON COLUMN public.initial_balance_contractor.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.initial_balance_contractor.operation_summa IS 'Сумма операции';

COMMENT ON COLUMN public.initial_balance_contractor.reference_id IS 'Ссылка на справочник контрагентов по которому определяется начальный остаток';

COMMENT ON COLUMN public.initial_balance_contractor.contract_id IS 'Договор с контрагентом';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_initial_balance_contractor_doc_number ON public.initial_balance_contractor USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER initial_balance_contractor_au_0
	AFTER UPDATE ON public.initial_balance_contractor
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.initial_balance_contractor_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_contractor_ad
	AFTER DELETE ON public.initial_balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER initial_balance_contractor_aiu
	AFTER INSERT OR UPDATE ON public.initial_balance_contractor
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_contractor_bi
	BEFORE INSERT ON public.initial_balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_contractor_bu
	BEFORE UPDATE ON public.initial_balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_contractor_au_1
	AFTER UPDATE ON public.initial_balance_contractor
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.initial_balance_contractor_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_contractor_au_2
	AFTER UPDATE ON public.initial_balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_contractor
	ADD CONSTRAINT pk_initial_balance_contractor_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_contractor
	ADD CONSTRAINT fk_initial_balance_contractor_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_contractor
	ADD CONSTRAINT fk_initial_balance_contractor_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_contractor
	ADD CONSTRAINT fk_initial_balance_contractor_reference FOREIGN KEY (reference_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_contractor
	ADD CONSTRAINT fk_initial_balance_contractor_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_contractor
	ADD CONSTRAINT fk_initial_balance_contractor_contract FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON UPDATE CASCADE;
