CREATE SEQUENCE public.gross_payroll_employee_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.gross_payroll_employee_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.gross_payroll_employee_id_seq TO users;

ALTER SEQUENCE public.gross_payroll_employee_id_seq
	OWNED BY public.gross_payroll_employee.id;
