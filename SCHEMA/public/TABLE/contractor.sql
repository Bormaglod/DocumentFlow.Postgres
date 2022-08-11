CREATE TABLE public.contractor (
)
INHERITS (public.company);

ALTER TABLE ONLY public.contractor ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.contractor ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.contractor ALTER COLUMN inn SET DEFAULT 0;

ALTER TABLE ONLY public.contractor ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.contractor ALTER COLUMN kpp SET DEFAULT 0;

ALTER TABLE ONLY public.contractor ALTER COLUMN ogrn SET DEFAULT 0;

ALTER TABLE ONLY public.contractor ALTER COLUMN okpo SET DEFAULT 0;

ALTER TABLE public.contractor OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.contractor TO users;

COMMENT ON TABLE public.contractor IS 'Контрагенты';

COMMENT ON COLUMN public.contractor.account_id IS 'Основной расчётный счёт';

COMMENT ON COLUMN public.contractor.okopf_id IS 'ОКОПФ';

--------------------------------------------------------------------------------

CREATE TRIGGER contractor_ad
	AFTER DELETE ON public.contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER contractor_aiu
	AFTER INSERT OR UPDATE ON public.contractor
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER contractor_aiu_0
	AFTER INSERT OR UPDATE ON public.contractor
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.company_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER contractor_bi
	BEFORE INSERT ON public.contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER contractor_bu
	BEFORE UPDATE ON public.contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT pk_contractor_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT unq_contractor_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_okopf FOREIGN KEY (okopf_id) REFERENCES public.okopf(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_parent FOREIGN KEY (parent_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_account FOREIGN KEY (id, account_id) REFERENCES public.account(owner_id, id) ON UPDATE CASCADE ON DELETE SET NULL;
