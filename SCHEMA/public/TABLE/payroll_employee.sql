CREATE TABLE public.payroll_employee (
	id bigint DEFAULT nextval('public.payroll_employee_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	employee_id uuid NOT NULL,
	wage numeric(15,2) NOT NULL
);

ALTER TABLE public.payroll_employee OWNER TO postgres;

COMMENT ON COLUMN public.payroll_employee.owner_id IS 'Платёжная аедомость';

COMMENT ON COLUMN public.payroll_employee.employee_id IS 'Сотрудник';

COMMENT ON COLUMN public.payroll_employee.wage IS 'Выплаченная сумма';

--------------------------------------------------------------------------------

ALTER TABLE public.payroll_employee
	ADD CONSTRAINT fk_payroll_employee_owner FOREIGN KEY (owner_id) REFERENCES public.payroll(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payroll_employee
	ADD CONSTRAINT fk_payroll_employee FOREIGN KEY (employee_id) REFERENCES public.our_employee(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payroll_employee
	ADD CONSTRAINT unq_payroll_employee UNIQUE (owner_id, employee_id);
