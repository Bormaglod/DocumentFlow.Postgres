CREATE TYPE public.price_setting_method AS ENUM (
	'average',
	'dictionary',
	'manual'
);

ALTER TYPE public.price_setting_method OWNER TO postgres;
