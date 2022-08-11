CREATE TABLE public.bank (
	bik numeric(9,0) DEFAULT 0 NOT NULL,
	account numeric(20,0) DEFAULT 0 NOT NULL,
	town character varying(30)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.bank ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.bank ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.bank ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.bank OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.bank TO users;

COMMENT ON TABLE public.bank IS 'Банки';

COMMENT ON COLUMN public.bank.bik IS 'БИК';

COMMENT ON COLUMN public.bank.account IS 'Номер корр. счёта';

COMMENT ON COLUMN public.bank.town IS 'Город';

--------------------------------------------------------------------------------

CREATE TRIGGER bank_ad
	AFTER DELETE ON public.bank
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER bank_aiu
	AFTER INSERT OR UPDATE ON public.bank
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER bank_aiu_0
	AFTER INSERT OR UPDATE ON public.bank
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.bank_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER bank_bi
	BEFORE INSERT ON public.bank
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER bank_biu_0
	BEFORE INSERT OR UPDATE ON public.bank
	FOR EACH ROW
	EXECUTE PROCEDURE public.bank_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER bank_bu
	BEFORE UPDATE ON public.bank
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT pk_bank_id UNIQUE (id);

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT unq_bank_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT fk_bank_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT fk_bank_parent FOREIGN KEY (parent_id) REFERENCES public.bank(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT fk_bank_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
