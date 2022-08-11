CREATE TYPE public.base_deduction AS ENUM (
	'material',
	'salary',
	'person'
);

ALTER TYPE public.base_deduction OWNER TO postgres;
