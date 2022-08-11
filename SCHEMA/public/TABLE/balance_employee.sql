CREATE TABLE public.balance_employee (
)
INHERITS (public.balance);

ALTER TABLE ONLY public.balance_employee ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.balance_employee ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.balance_employee ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.balance_employee ALTER COLUMN operation_summa SET DEFAULT 0;

ALTER TABLE public.balance_employee OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.balance_employee TO users;

COMMENT ON COLUMN public.balance_employee.amount IS 'Число больше 0 определяет увеличение долга сотрудника, меньше 0 - уменьшение долга сотрудника';

COMMENT ON COLUMN public.balance_employee.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.balance_employee.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.balance_employee.document_type_id IS 'Ссылка на тип документа который сформировал эту запись';

COMMENT ON COLUMN public.balance_employee.operation_summa IS 'Сумма операции';

COMMENT ON COLUMN public.balance_employee.owner_id IS 'Ссылка на документ который сформировал эту запись';

COMMENT ON COLUMN public.balance_employee.reference_id IS 'Ссылка на сотрудника по которому считаются долги';

--------------------------------------------------------------------------------

CREATE INDEX idx_balance_employee_owner ON public.balance_employee USING btree (owner_id);

--------------------------------------------------------------------------------

CREATE TRIGGER balance_employee_ad
	AFTER DELETE ON public.balance_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_employee_ad_0
	AFTER DELETE ON public.balance_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.balance_employee_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_employee_aiu
	AFTER INSERT OR UPDATE ON public.balance_employee
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_employee_aiu_0
	AFTER INSERT OR UPDATE ON public.balance_employee
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.balance_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_employee_bi
	BEFORE INSERT ON public.balance_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_employee_bu
	BEFORE UPDATE ON public.balance_employee
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.balance_employee
	ADD CONSTRAINT pk_balance_employee_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.balance_employee
	ADD CONSTRAINT fk_balance_employee_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_employee
	ADD CONSTRAINT fk_balance_employee_document_type FOREIGN KEY (document_type_id) REFERENCES public.document_type(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_employee
	ADD CONSTRAINT fk_balance_employee_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_employee
	ADD CONSTRAINT fk_balance_employee_reference FOREIGN KEY (reference_id) REFERENCES public.our_employee(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_employee
	ADD CONSTRAINT fk_balance_employee_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
