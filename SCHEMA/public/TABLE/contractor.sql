CREATE TABLE public.contractor (
	tax_payer boolean,
	supplier boolean,
	buyer boolean
)
INHERITS (public.company);

ALTER TABLE ONLY public.contractor ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.contractor OWNER TO postgres;

GRANT ALL ON TABLE public.contractor TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.contractor TO users;

COMMENT ON COLUMN public.contractor.tax_payer IS 'Плательщик НДС';

COMMENT ON COLUMN public.contractor.supplier IS 'Поставщик';

COMMENT ON COLUMN public.contractor.buyer IS 'Покупатель';

--------------------------------------------------------------------------------

CREATE TRIGGER contractor_ad
	AFTER DELETE ON public.contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER contractor_aiu
	AFTER INSERT OR UPDATE ON public.contractor
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

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

CREATE TRIGGER contractor_au_status
	AFTER UPDATE ON public.contractor
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_company();

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT pk_contractor_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT unq_contractor_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_account FOREIGN KEY (account_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_okopf FOREIGN KEY (okopf_id) REFERENCES public.okopf(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_parent FOREIGN KEY (parent_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contractor
	ADD CONSTRAINT fk_contractor_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
