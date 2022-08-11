CREATE TYPE public.payment_direction AS ENUM (
	'income',
	'expense'
);

ALTER TYPE public.payment_direction OWNER TO postgres;
