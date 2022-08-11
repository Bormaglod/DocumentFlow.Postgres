CREATE SEQUENCE public.wage1c_employee_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.wage1c_employee_id_seq OWNER TO postgres;

ALTER SEQUENCE public.wage1c_employee_id_seq
	OWNED BY public.wage1c_employee.id;
