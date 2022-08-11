CREATE TABLE public.employee (
	person_id uuid,
	post_id uuid,
	phone character varying(30),
	email character varying(100),
	j_role public.job_role
)
INHERITS (public.directory);

ALTER TABLE ONLY public.employee ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.employee ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.employee ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.employee ALTER COLUMN owner_id SET NOT NULL;

ALTER TABLE public.employee OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.employee TO users;

COMMENT ON TABLE public.employee IS 'Сотрудники контрагентов';

COMMENT ON COLUMN public.employee.item_name IS 'Сотрудник (имя, фамилия)';

COMMENT ON COLUMN public.employee.person_id IS 'Ссылка на физ. лицо представляющее сотрудника';

COMMENT ON COLUMN public.employee.post_id IS 'Должность сотрудника';

COMMENT ON COLUMN public.employee.phone IS 'Рабочий телефон';

COMMENT ON COLUMN public.employee.email IS 'Рабочий адрес электронной почты';

COMMENT ON COLUMN public.employee.j_role IS 'Должностная роль';

--------------------------------------------------------------------------------

CREATE TRIGGER employee_ad
	AFTER DELETE ON public.employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER employee_aiu
	AFTER INSERT OR UPDATE ON public.employee
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER employee_aiu_0
	AFTER INSERT OR UPDATE ON public.employee
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.employee_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER employee_bi
	BEFORE INSERT ON public.employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER employee_biu_0
	BEFORE INSERT OR UPDATE ON public.employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.employee_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER employee_bu
	BEFORE UPDATE ON public.employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT pk_employee_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT unq_employee_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_contractor FOREIGN KEY (owner_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_parent FOREIGN KEY (parent_id) REFERENCES public.employee(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_person FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_post FOREIGN KEY (post_id) REFERENCES public.okpdtr(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT fk_employee_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.employee
	ADD CONSTRAINT unq_employee_person UNIQUE (owner_id, person_id);
