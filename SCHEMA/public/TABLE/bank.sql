CREATE TABLE public.bank (
	bik numeric(9,0),
	account numeric(20,0)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.bank ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.bank OWNER TO postgres;

GRANT ALL ON TABLE public.bank TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.bank TO users;

COMMENT ON TABLE public.bank IS 'Банки';

COMMENT ON COLUMN public.bank.bik IS 'БИК';

COMMENT ON COLUMN public.bank.account IS 'Номер корр. счёта';

--------------------------------------------------------------------------------

CREATE TRIGGER bank_ad
	AFTER DELETE ON public.bank
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER bank_aiu
	AFTER INSERT OR UPDATE ON public.bank
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER bank_au_status
	AFTER UPDATE ON public.bank
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_bank();

--------------------------------------------------------------------------------

CREATE TRIGGER bank_bi
	BEFORE INSERT ON public.bank
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

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
	ADD CONSTRAINT fk_bank_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT fk_bank_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT fk_bank_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT fk_bank_parent FOREIGN KEY (parent_id) REFERENCES public.bank(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT fk_bank_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT fk_bank_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.bank
	ADD CONSTRAINT unq_bank_code UNIQUE (code);
