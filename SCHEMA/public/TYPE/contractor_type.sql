CREATE TYPE public.contractor_type AS ENUM (
	'seller',
	'buyer'
);

ALTER TYPE public.contractor_type OWNER TO postgres;

COMMENT ON TYPE public.contractor_type IS 'продвец
покупатель
';
