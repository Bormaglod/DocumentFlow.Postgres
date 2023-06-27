CREATE TABLE public.account (
	account_value numeric(20,0) DEFAULT 0 NOT NULL,
	bank_id uuid
)
INHERITS (public.directory);

ALTER TABLE ONLY public.account ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.account ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.account ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.account ALTER COLUMN owner_id SET NOT NULL;

ALTER TABLE public.account OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.account TO users;

COMMENT ON TABLE public.account IS 'Расчётные счета';

COMMENT ON COLUMN public.account.owner_id IS 'Контрагент, которому принадлежит счет';

COMMENT ON COLUMN public.account.account_value IS 'Номер расчётного счёта';

COMMENT ON COLUMN public.account.bank_id IS 'Банк';

--------------------------------------------------------------------------------

CREATE TRIGGER account_ad
	AFTER DELETE ON public.account
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER account_aiu
	AFTER INSERT OR UPDATE ON public.account
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER account_aiu_0
	AFTER INSERT OR UPDATE ON public.account
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.account_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER account_bi
	BEFORE INSERT ON public.account
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER account_biu_0
	BEFORE INSERT OR UPDATE ON public.account
	FOR EACH ROW
	EXECUTE PROCEDURE public.account_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER account_bu
	BEFORE UPDATE ON public.account
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT pk_account_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT unq_account_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_bank FOREIGN KEY (bank_id) REFERENCES public.bank(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_owner FOREIGN KEY (owner_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_parent FOREIGN KEY (parent_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT unq_account_id_owner UNIQUE (id, owner_id);
