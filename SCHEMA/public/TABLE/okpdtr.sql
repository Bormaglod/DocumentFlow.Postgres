CREATE TABLE public.okpdtr (
	signatory_name character varying(255)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.okpdtr ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.okpdtr ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.okpdtr ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.okpdtr OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.okpdtr TO users;

COMMENT ON COLUMN public.okpdtr.signatory_name IS 'Наименование должности исплдьзуемое в договорах';

--------------------------------------------------------------------------------

CREATE TRIGGER okpdtr_ad
	AFTER DELETE ON public.okpdtr
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER okpdtr_aiu
	AFTER INSERT OR UPDATE ON public.okpdtr
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER okpdtr_bi
	BEFORE INSERT ON public.okpdtr
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER okpdtr_bu
	BEFORE UPDATE ON public.okpdtr
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.okpdtr
	ADD CONSTRAINT pk_okpdtr_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.okpdtr
	ADD CONSTRAINT unq_okpdtr_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.okpdtr
	ADD CONSTRAINT fk_okpdtr_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.okpdtr
	ADD CONSTRAINT fk_okpdtr_parent FOREIGN KEY (parent_id) REFERENCES public.okpdtr(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.okpdtr
	ADD CONSTRAINT fk_okpdtr_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
