CREATE TABLE public.initial_balance_employee (
)
INHERITS (public.initial_balance);

ALTER TABLE ONLY public.initial_balance_employee ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.initial_balance_employee ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance_employee ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance_employee ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.initial_balance_employee ALTER COLUMN operation_summa SET DEFAULT 0;

ALTER TABLE ONLY public.initial_balance_employee ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance_employee ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.initial_balance_employee OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.initial_balance_employee TO users;

COMMENT ON COLUMN public.initial_balance_employee.amount IS 'Число больше 0 определяет задолженность сотрудника, меньше 0 - задолженность организации перед сотрудником';

COMMENT ON COLUMN public.initial_balance_employee.document_date IS 'Дата на которую определен остаток';

COMMENT ON COLUMN public.initial_balance_employee.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.initial_balance_employee.operation_summa IS 'Сумма операции';

COMMENT ON COLUMN public.initial_balance_employee.reference_id IS 'Ссылка на справочник сотрудников по которому определяется начальный остаток';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_initial_balance_employee_doc_number ON public.initial_balance_employee USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_employee_ad
	AFTER DELETE ON public.initial_balance_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER initial_balance_employee_aiu
	AFTER INSERT OR UPDATE ON public.initial_balance_employee
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER initial_balance_employee_au_0
	AFTER UPDATE ON public.initial_balance_employee
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.initial_balance_employee_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_employee_au_1
	AFTER UPDATE ON public.initial_balance_employee
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.initial_balance_employee_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_employee_au_2
	AFTER UPDATE ON public.initial_balance_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_employee_bi
	BEFORE INSERT ON public.initial_balance_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_employee_bu
	BEFORE UPDATE ON public.initial_balance_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_employee
	ADD CONSTRAINT fk_initial_balance_employee_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_employee
	ADD CONSTRAINT fk_initial_balance_employee_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_employee
	ADD CONSTRAINT fk_initial_balance_employee_reference FOREIGN KEY (reference_id) REFERENCES public.our_employee(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_employee
	ADD CONSTRAINT fk_initial_initial_balance_employee_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_employee
	ADD CONSTRAINT pk_initial_balance_employee_id PRIMARY KEY (id);
