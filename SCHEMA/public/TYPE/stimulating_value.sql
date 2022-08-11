CREATE TYPE public.stimulating_value AS ENUM (
	'money',
	'percent'
);

ALTER TYPE public.stimulating_value OWNER TO postgres;
