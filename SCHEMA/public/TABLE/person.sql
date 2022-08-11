CREATE TABLE public.person (
	surname character varying(40),
	first_name character varying(20),
	middle_name character varying(40),
	phone character varying(30),
	email character varying(100)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.person ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.person ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.person OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.person TO users;

COMMENT ON TABLE public.person IS 'Физические лица';

COMMENT ON COLUMN public.person.surname IS 'Фамилия';

COMMENT ON COLUMN public.person.first_name IS 'Имя';

COMMENT ON COLUMN public.person.middle_name IS 'Отчество';

COMMENT ON COLUMN public.person.phone IS 'Личный телефон';

COMMENT ON COLUMN public.person.email IS 'Адрес эл. почты';

--------------------------------------------------------------------------------

CREATE TRIGGER person_ad
	AFTER DELETE ON public.person
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

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

CREATE TRIGGER person_biu_0
	BEFORE INSERT OR UPDATE ON public.person
	FOR EACH ROW
	EXECUTE PROCEDURE public.person_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER person_bu
	BEFORE UPDATE ON public.person
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER person_aiu_0
	AFTER INSERT OR UPDATE ON public.person
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.person_checking();

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT pk_person_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT unq_person_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT fk_person_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT fk_person_parent FOREIGN KEY (parent_id) REFERENCES public.person(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.person
	ADD CONSTRAINT fk_person_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
