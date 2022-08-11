CREATE TABLE public.wage1c_employee (
	id bigint DEFAULT nextval('public.wage1c_employee_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	employee_id uuid NOT NULL,
	wage numeric(15,2) NOT NULL
);

ALTER TABLE public.wage1c_employee OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.wage1c_employee TO users;

COMMENT ON COLUMN public.wage1c_employee.owner_id IS 'Ведомость начисления';

COMMENT ON COLUMN public.wage1c_employee.employee_id IS 'Сотрудник';

COMMENT ON COLUMN public.wage1c_employee.wage IS 'Заработная плата';

--------------------------------------------------------------------------------

ALTER TABLE public.wage1c_employee
	ADD CONSTRAINT pk_wage1c_employee_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.wage1c_employee
	ADD CONSTRAINT fk_wage1c_employee_our FOREIGN KEY (employee_id) REFERENCES public.our_employee(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.wage1c_employee
	ADD CONSTRAINT fk_wage1c_employee_owner FOREIGN KEY (owner_id) REFERENCES public.wage1c(id) ON UPDATE CASCADE ON DELETE CASCADE;
