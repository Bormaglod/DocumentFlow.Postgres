CREATE TABLE public.balance_contractor (
	contract_id uuid NOT NULL
)
INHERITS (public.balance);

ALTER TABLE ONLY public.balance_contractor ALTER COLUMN amount SET DEFAULT NULL::numeric;

ALTER TABLE ONLY public.balance_contractor ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.balance_contractor ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.balance_contractor ALTER COLUMN operation_summa SET DEFAULT 0;

ALTER TABLE public.balance_contractor OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.balance_contractor TO users;

COMMENT ON COLUMN public.balance_contractor.amount IS 'Число больше 0 определяет увеличение долга контрагента, меньше 0 - уменьшение долга';

COMMENT ON COLUMN public.balance_contractor.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.balance_contractor.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.balance_contractor.document_type_id IS 'Ссылка на тип документа который сформировал эту запись';

COMMENT ON COLUMN public.balance_contractor.operation_summa IS 'Сумма операции';

COMMENT ON COLUMN public.balance_contractor.owner_id IS 'Ссылка на документ который сформировал эту запись';

COMMENT ON COLUMN public.balance_contractor.reference_id IS 'Ссылка на контрагента по которому считаются долги';

COMMENT ON COLUMN public.balance_contractor.contract_id IS 'Договор с контрагентом';

--------------------------------------------------------------------------------

CREATE INDEX idx_balance_contractor_owner ON public.balance_contractor USING btree (owner_id);

--------------------------------------------------------------------------------

CREATE TRIGGER balance_contractor_ad
	AFTER DELETE ON public.balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_contractor_aiu
	AFTER INSERT OR UPDATE ON public.balance_contractor
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_contractor_bi
	BEFORE INSERT ON public.balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_contractor_bu
	BEFORE UPDATE ON public.balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_contractor_aiu_0
	AFTER INSERT OR UPDATE ON public.balance_contractor
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.balance_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_contractor_ad_0
	AFTER DELETE ON public.balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.balance_contractor_deleted();

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT pk_balance_contractor_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_document_type FOREIGN KEY (document_type_id) REFERENCES public.document_type(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_reference FOREIGN KEY (reference_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;
