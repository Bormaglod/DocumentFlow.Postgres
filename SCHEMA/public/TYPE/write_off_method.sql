CREATE TYPE public.write_off_method AS ENUM (
	'consumption',
	'return'
);

ALTER TYPE public.write_off_method OWNER TO postgres;
