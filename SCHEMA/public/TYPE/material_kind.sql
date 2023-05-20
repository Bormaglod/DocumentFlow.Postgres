CREATE TYPE public.material_kind AS ENUM (
	'undefined',
	'wire',
	'terminal',
	'housing',
	'seal'
);

ALTER TYPE public.material_kind OWNER TO postgres;
