CREATE TABLE public.gross_payroll_employee (
	id bigint DEFAULT nextval('public.gross_payroll_employee_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	employee_id uuid NOT NULL,
	income_item_id uuid NOT NULL,
	wage numeric(15,2) NOT NULL
);

ALTER TABLE public.gross_payroll_employee OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.gross_payroll_employee TO payroll_accountant;

COMMENT ON COLUMN public.gross_payroll_employee.owner_id IS 'Ведомость начисления';

COMMENT ON COLUMN public.gross_payroll_employee.employee_id IS 'Сотрудник';

COMMENT ON COLUMN public.gross_payroll_employee.income_item_id IS 'Статья дохода';

COMMENT ON COLUMN public.gross_payroll_employee.wage IS 'Заработная плата';

--------------------------------------------------------------------------------

ALTER TABLE public.gross_payroll_employee
	ADD CONSTRAINT fk_gross_payroll_employee_owner FOREIGN KEY (owner_id) REFERENCES public.gross_payroll(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.gross_payroll_employee
	ADD CONSTRAINT pk_gross_payroll_employee_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.gross_payroll_employee
	ADD CONSTRAINT fk_gross_payroll_employee_income FOREIGN KEY (income_item_id) REFERENCES public.income_item(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.gross_payroll_employee
	ADD CONSTRAINT fk_gross_payroll_employee_our FOREIGN KEY (employee_id) REFERENCES public.our_employee(id) ON UPDATE CASCADE;
