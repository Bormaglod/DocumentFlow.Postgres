CREATE TABLE public.organization (
	default_org boolean DEFAULT false NOT NULL,
	address character varying(250),
	phone character varying(100),
	email character varying(100)
)
INHERITS (public.company);

ALTER TABLE ONLY public.organization ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.organization ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.organization ALTER COLUMN inn SET DEFAULT 0;

ALTER TABLE ONLY public.organization ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.organization ALTER COLUMN kpp SET DEFAULT 0;

ALTER TABLE ONLY public.organization ALTER COLUMN ogrn SET DEFAULT 0;

ALTER TABLE ONLY public.organization ALTER COLUMN okpo SET DEFAULT 0;

ALTER TABLE public.organization OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.organization TO users;

COMMENT ON TABLE public.organization IS 'Наши организации';

COMMENT ON COLUMN public.organization.account_id IS 'Основной расчётный счёт';

COMMENT ON COLUMN public.organization.full_name IS 'Полное наименование';

COMMENT ON COLUMN public.organization.item_name IS 'Короткое наименование';

COMMENT ON COLUMN public.organization.okopf_id IS 'ОКОПФ';

COMMENT ON COLUMN public.organization.address IS 'Юридический адрес';

COMMENT ON COLUMN public.organization.phone IS 'Основной рабочий телефон';

COMMENT ON COLUMN public.organization.email IS 'Адрес электронной почты';

--------------------------------------------------------------------------------

CREATE TRIGGER organization_ad
	AFTER DELETE ON public.organization
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER organization_aiu
	AFTER INSERT OR UPDATE ON public.organization
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER organization_aiu_0
	AFTER INSERT OR UPDATE ON public.organization
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.company_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER organization_bi
	BEFORE INSERT ON public.organization
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER organization_bu
	BEFORE UPDATE ON public.organization
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT pk_organization_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT unq_organization_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_account FOREIGN KEY (account_id) REFERENCES public.our_account(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_okopf FOREIGN KEY (okopf_id) REFERENCES public.okopf(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_parent FOREIGN KEY (parent_id) REFERENCES public.organization(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
