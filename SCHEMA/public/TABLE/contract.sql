CREATE TABLE public.contract (
	tax_payer boolean DEFAULT true NOT NULL,
	is_default boolean,
	c_type public.contractor_type NOT NULL,
	organization_id uuid NOT NULL,
	document_date date NOT NULL,
	date_start date NOT NULL,
	date_end date,
	signatory_id uuid,
	org_signatory_id uuid,
	payment_period smallint
)
INHERITS (public.directory);

ALTER TABLE ONLY public.contract ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.contract ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.contract ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.contract ALTER COLUMN owner_id SET NOT NULL;

ALTER TABLE public.contract OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.contract TO users;

COMMENT ON TABLE public.contract IS 'Договора с контрагентами';

COMMENT ON COLUMN public.contract.code IS 'Номер договора';

COMMENT ON COLUMN public.contract.item_name IS 'Наименование договора';

COMMENT ON COLUMN public.contract.owner_id IS 'Контрагент';

COMMENT ON COLUMN public.contract.tax_payer IS 'Плательщик НДС';

COMMENT ON COLUMN public.contract.c_type IS 'Вид договора';

COMMENT ON COLUMN public.contract.organization_id IS 'Наша организация';

COMMENT ON COLUMN public.contract.document_date IS 'Дата договора';

COMMENT ON COLUMN public.contract.date_start IS 'Начало действия договора';

COMMENT ON COLUMN public.contract.date_end IS 'Окончание действия договора';

COMMENT ON COLUMN public.contract.signatory_id IS 'Лицо подписывающее договор со стороны контрагента';

COMMENT ON COLUMN public.contract.org_signatory_id IS 'Лицо подписывающее договор со стороны нашей организации';

COMMENT ON COLUMN public.contract.payment_period IS 'Период в течении которого ожидается оплата';

--------------------------------------------------------------------------------

CREATE TRIGGER contract_ad
	AFTER DELETE ON public.contract
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER contract_aiu
	AFTER INSERT OR UPDATE ON public.contract
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER contract_aiu_0
	AFTER INSERT OR UPDATE ON public.contract
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.contract_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER contract_bi
	BEFORE INSERT ON public.contract
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER contract_bu
	BEFORE UPDATE ON public.contract
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER contract_bi_0
	BEFORE INSERT ON public.contract
	FOR EACH ROW
	EXECUTE PROCEDURE public.contract_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER contract_au_0
	AFTER UPDATE ON public.contract
	FOR EACH ROW
	EXECUTE PROCEDURE public.contract_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT pk_contract_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT unq_contract_code UNIQUE (owner_id, organization_id, code);

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_contractor FOREIGN KEY (owner_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_signatory FOREIGN KEY (signatory_id) REFERENCES public.employee(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_org_signatory FOREIGN KEY (org_signatory_id) REFERENCES public.our_employee(id) ON UPDATE CASCADE ON DELETE SET NULL;
