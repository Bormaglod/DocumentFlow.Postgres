CREATE TABLE public.okopf (
)
INHERITS (public.directory);

ALTER TABLE ONLY public.okopf ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.okopf OWNER TO postgres;

GRANT ALL ON TABLE public.okopf TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.okopf TO users;

COMMENT ON TABLE public.okopf IS 'Общероссийский классификатор организационно-правовых форм';

--------------------------------------------------------------------------------

CREATE TRIGGER okopf_ad
	AFTER DELETE ON public.okopf
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE TRIGGER okopf_bi
	BEFORE INSERT ON public.okopf
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER okopf_bu
	BEFORE UPDATE ON public.okopf
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER okopf_aiu
	AFTER INSERT OR UPDATE ON public.okopf
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

ALTER TABLE public.okopf
	ADD CONSTRAINT pk_okopf_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.okopf
	ADD CONSTRAINT unq_okopf_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.okopf
	ADD CONSTRAINT fk_okopf_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.okopf
	ADD CONSTRAINT fk_okopf_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.okopf
	ADD CONSTRAINT fk_okopf_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.okopf
	ADD CONSTRAINT fk_okopf_parent FOREIGN KEY (parent_id) REFERENCES public.okopf(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.okopf
	ADD CONSTRAINT fk_okopf_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.okopf
	ADD CONSTRAINT fk_okopf_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
