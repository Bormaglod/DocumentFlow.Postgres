CREATE TYPE public.purchase_state AS ENUM (
	'not active',
	'active',
	'canceled',
	'completed'
);

ALTER TYPE public.purchase_state OWNER TO postgres;
