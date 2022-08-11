CREATE TYPE public.job_role AS ENUM (
	'not_defined',
	'director',
	'chief_accountant',
	'employee',
	'worker'
);

ALTER TYPE public.job_role OWNER TO postgres;
