CREATE TABLE public.employee (
	person_id uuid,
	post_id uuid,
	phone character varying(30),
	email character varying(100),
	post_role integer
)
INHERITS (public.directory);

ALTER TABLE ONLY public.employee ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.employee OWNER TO postgres;

GRANT ALL ON TABLE public.employee TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.employee TO users;

--------------------------------------------------------------------------------

CREATE TRIGGER employee_ad
	AFTER DELETE ON public.employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER employee_aiu
	AFTER INSERT OR UPDATE ON public.employee
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER employee_bi
	BEFORE INSERT ON public.employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER employee_bu
	BEFORE UPDATE ON public.employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER employee_au_status
	AFTER UPDATE ON public.employee
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_employee();

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT pk_employee_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT unq_employee_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_parent FOREIGN KEY (parent_id) REFERENCES public.employee(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_person FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_post FOREIGN KEY (post_id) REFERENCES public.okpdtr(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT chk_employee_post_role CHECK (((post_role >= 0) AND (post_role < 5)));

COMMENT ON CONSTRAINT chk_employee_post_role ON public.employee IS 'Неверно установлено щначение роли служащего. Допустимые значения: 
0 - роль неопределена
1 - руководитель
2 - гл. бухгалтер
3 - служащий
4 - рабочий';
