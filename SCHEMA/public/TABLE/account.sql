CREATE TABLE public.account (
	account_value numeric(20,0),
	bank_id uuid
)
INHERITS (public.directory);

ALTER TABLE ONLY public.account ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.account OWNER TO postgres;

GRANT ALL ON TABLE public.account TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.account TO users;

COMMENT ON TABLE public.account IS 'Расчётные счета';

COMMENT ON COLUMN public.account.account_value IS 'Номер расчётного счёта';

COMMENT ON COLUMN public.account.bank_id IS 'Банк';

--------------------------------------------------------------------------------

CREATE TRIGGER account_ad
	AFTER DELETE ON public.account
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER account_aiu
	AFTER INSERT OR UPDATE ON public.account
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER account_bi
	BEFORE INSERT ON public.account
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER account_bu
	BEFORE UPDATE ON public.account
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER account_au_status
	AFTER UPDATE ON public.account
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_account();

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT pk_account_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT unq_account_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_parent FOREIGN KEY (parent_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.account
	ADD CONSTRAINT fk_account_bank FOREIGN KEY (bank_id) REFERENCES public.bank(id) ON UPDATE CASCADE;
