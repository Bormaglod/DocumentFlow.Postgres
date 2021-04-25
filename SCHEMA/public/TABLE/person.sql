CREATE TABLE public.person (
	surname character varying(40),
	first_name character varying(20),
	middle_name character varying(40),
	phone character varying(30),
	email character varying(100)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.person OWNER TO postgres;

GRANT ALL ON TABLE public.person TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.person TO users;

COMMENT ON TABLE public.person IS 'Физические лица';

COMMENT ON COLUMN public.person.surname IS 'Фамилия';

COMMENT ON COLUMN public.person.first_name IS 'Имя';

COMMENT ON COLUMN public.person.middle_name IS 'Отчество';

COMMENT ON COLUMN public.person.phone IS 'Телефон';

COMMENT ON COLUMN public.person.email IS 'Адрес эл. почты';

--------------------------------------------------------------------------------

CREATE TRIGGER person_ad
	AFTER DELETE ON public.person
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER person_aiu
	AFTER INSERT OR UPDATE ON public.person
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER person_bi
	BEFORE INSERT ON public.person
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER person_bu
	BEFORE UPDATE ON public.person
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER person_bu_status
	BEFORE UPDATE ON public.person
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_person();

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT pk_person_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT fk_person_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT fk_person_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT fk_person_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT fk_person_parent FOREIGN KEY (parent_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT fk_person_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT fk_person_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT unq_person_code UNIQUE (code);
