CREATE TABLE public.organization (
	default_org boolean,
	address character varying(250),
	phone character varying(100),
	email character varying(100)
)
INHERITS (public.company);

ALTER TABLE ONLY public.organization ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.organization OWNER TO postgres;

GRANT ALL ON TABLE public.organization TO admins;
GRANT SELECT ON TABLE public.organization TO users;
GRANT SELECT,INSERT,UPDATE ON TABLE public.organization TO sergio;

--------------------------------------------------------------------------------

CREATE TRIGGER organization_ad
	AFTER DELETE ON public.organization
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER organization_aiu
	AFTER INSERT OR UPDATE ON public.organization
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER organization_au_status
	AFTER UPDATE ON public.organization
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_company();

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
	ADD CONSTRAINT fk_organization_account FOREIGN KEY (account_id) REFERENCES public.account(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_okopf FOREIGN KEY (okopf_id) REFERENCES public.okopf(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_parent FOREIGN KEY (parent_id) REFERENCES public.organization(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT fk_organization_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.organization
	ADD CONSTRAINT unq_organization_code UNIQUE (code);
