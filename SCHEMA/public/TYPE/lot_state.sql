CREATE TYPE public.lot_state AS ENUM (
	'created',
	'production',
	'completed'
);

ALTER TYPE public.lot_state OWNER TO postgres;
