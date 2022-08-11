CREATE TABLE public.our_employee (
	income_items character varying[]
)
INHERITS (public.employee);

ALTER TABLE ONLY public.our_employee ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.our_employee ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.our_employee ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.our_employee OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.our_employee TO users;

--------------------------------------------------------------------------------

CREATE TRIGGER our_employee_ad
	AFTER DELETE ON public.our_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER our_employee_aiu
	AFTER INSERT OR UPDATE ON public.our_employee
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER our_employee_aiu_0
	AFTER INSERT OR UPDATE ON public.our_employee
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.employee_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER our_employee_bi
	BEFORE INSERT ON public.our_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER our_employee_biu_0
	BEFORE INSERT OR UPDATE ON public.our_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.employee_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER our_employee_bu
	BEFORE UPDATE ON public.our_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.our_employee
	ADD CONSTRAINT pk_our_employee_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.our_employee
	ADD CONSTRAINT unq_our_employee_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.our_employee
	ADD CONSTRAINT fk_our_employee_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.our_employee
	ADD CONSTRAINT fk_our_employee_org FOREIGN KEY (owner_id) REFERENCES public.organization(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.our_employee
	ADD CONSTRAINT fk_our_employee_parent FOREIGN KEY (parent_id) REFERENCES public.employee(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.our_employee
	ADD CONSTRAINT fk_our_employee_person FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.our_employee
	ADD CONSTRAINT fk_our_employee_post FOREIGN KEY (post_id) REFERENCES public.okpdtr(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.our_employee
	ADD CONSTRAINT fk_our_employee_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
