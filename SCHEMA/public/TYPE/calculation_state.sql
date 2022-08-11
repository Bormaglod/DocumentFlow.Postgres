CREATE TYPE public.calculation_state AS ENUM (
	'prepare',
	'approved',
	'expired'
);

ALTER TYPE public.calculation_state OWNER TO postgres;
