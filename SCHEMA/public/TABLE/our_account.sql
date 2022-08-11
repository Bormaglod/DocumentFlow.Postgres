CREATE TABLE public.our_account (
)
INHERITS (public.account);

ALTER TABLE ONLY public.our_account ALTER COLUMN account_value SET DEFAULT 0;

ALTER TABLE ONLY public.our_account ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.our_account ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.our_account ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.our_account OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.our_account TO users;

COMMENT ON TABLE public.our_account IS 'Расчётные счета наших оршанизаций';

COMMENT ON COLUMN public.our_account.account_value IS 'Номер расчётного счёта';

COMMENT ON COLUMN public.our_account.bank_id IS 'Банк в котором открыт расчётный счёт';

--------------------------------------------------------------------------------

CREATE TRIGGER our_account_ad
	AFTER DELETE ON public.our_account
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER our_account_aiu
	AFTER INSERT OR UPDATE ON public.our_account
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER our_account_aiu_0
	AFTER INSERT OR UPDATE ON public.our_account
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.account_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER our_account_bi
	BEFORE INSERT ON public.our_account
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER our_account_biu_0
	BEFORE INSERT OR UPDATE ON public.our_account
	FOR EACH ROW
	EXECUTE PROCEDURE public.account_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER our_account_bu
	BEFORE UPDATE ON public.our_account
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.our_account
	ADD CONSTRAINT pk_our_account_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.our_account
	ADD CONSTRAINT unq_our_account_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.our_account
	ADD CONSTRAINT fk_our_account_bank FOREIGN KEY (bank_id) REFERENCES public.bank(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.our_account
	ADD CONSTRAINT fk_our_account_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.our_account
	ADD CONSTRAINT fk_our_account_owner FOREIGN KEY (owner_id) REFERENCES public.organization(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.our_account
	ADD CONSTRAINT fk_our_account_parent FOREIGN KEY (parent_id) REFERENCES public.our_account(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.our_account
	ADD CONSTRAINT fk_our_account_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
