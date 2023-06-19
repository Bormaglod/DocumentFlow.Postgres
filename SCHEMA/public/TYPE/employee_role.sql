CREATE TYPE public.employee_role AS ENUM (
	'not defined',
	'director',
	'chief accountant',
	'employee',
	'worker'
);

ALTER TYPE public.employee_role OWNER TO postgres;
