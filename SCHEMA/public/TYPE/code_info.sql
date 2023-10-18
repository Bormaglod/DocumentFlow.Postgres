CREATE TYPE public.code_info AS ENUM (
	'brand',
	'model',
	'engine',
	'type'
);

ALTER TYPE public.code_info OWNER TO postgres;
