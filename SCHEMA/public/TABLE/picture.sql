CREATE TABLE public.picture (
	size_small text,
	size_large text,
	img_name character varying(255),
	note text
)
INHERITS (public.directory);

ALTER TABLE ONLY public.picture ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.picture OWNER TO postgres;

GRANT ALL ON TABLE public.picture TO admins;
GRANT SELECT ON TABLE public.picture TO users;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.picture TO designers;

COMMENT ON TABLE public.picture IS 'Изображения/иконки';

--------------------------------------------------------------------------------

CREATE TRIGGER picture_ad
	AFTER DELETE ON public.picture
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER picture_aiu
	AFTER INSERT OR UPDATE ON public.picture
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER picture_bi
	BEFORE INSERT ON public.picture
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER picture_bu
	BEFORE UPDATE ON public.picture
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.picture
	ADD CONSTRAINT pk_picture_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.picture
	ADD CONSTRAINT fk_picture_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.picture
	ADD CONSTRAINT fk_picture_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.picture
	ADD CONSTRAINT fk_picture_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.picture
	ADD CONSTRAINT fk_picture_parent FOREIGN KEY (parent_id) REFERENCES public.picture(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.picture
	ADD CONSTRAINT fk_picture_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.picture
	ADD CONSTRAINT fk_picture_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.picture
	ADD CONSTRAINT unq_picture_code UNIQUE (code);
