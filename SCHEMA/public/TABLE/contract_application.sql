CREATE TABLE public.contract_application (
	document_date date NOT NULL,
	date_start date NOT NULL,
	date_end date,
	note text
)
INHERITS (public.directory);

ALTER TABLE ONLY public.contract_application ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.contract_application ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.contract_application ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.contract_application ALTER COLUMN owner_id SET NOT NULL;

ALTER TABLE public.contract_application OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.contract_application TO users;

COMMENT ON TABLE public.contract_application IS 'Приложения к договорам';

COMMENT ON COLUMN public.contract_application.code IS 'Номер приложения';

COMMENT ON COLUMN public.contract_application.item_name IS 'Наименование приложения';

COMMENT ON COLUMN public.contract_application.owner_id IS 'Договор';

COMMENT ON COLUMN public.contract_application.document_date IS 'Дата подписания';

COMMENT ON COLUMN public.contract_application.date_start IS 'Начало действия';

COMMENT ON COLUMN public.contract_application.date_end IS 'Окончание действия';

COMMENT ON COLUMN public.contract_application.note IS 'Примечание';

--------------------------------------------------------------------------------

CREATE TRIGGER contract_application_ad
	AFTER DELETE ON public.contract_application
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER contract_application_aiu
	AFTER INSERT OR UPDATE ON public.contract_application
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER contract_application_bi
	BEFORE INSERT ON public.contract_application
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER contract_application_bu
	BEFORE UPDATE ON public.contract_application
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER contract_application_aiu_0
	AFTER INSERT OR UPDATE ON public.contract_application
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.contract_application_checking();

--------------------------------------------------------------------------------

ALTER TABLE public.contract_application
	ADD CONSTRAINT pk_contract_application_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.contract_application
	ADD CONSTRAINT unq_contract_application_code UNIQUE (owner_id, code);

--------------------------------------------------------------------------------

ALTER TABLE public.contract_application
	ADD CONSTRAINT fk_contract_application_contract FOREIGN KEY (owner_id) REFERENCES public.contract(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract_application
	ADD CONSTRAINT fk_contract_application_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract_application
	ADD CONSTRAINT fk_contract_application_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
