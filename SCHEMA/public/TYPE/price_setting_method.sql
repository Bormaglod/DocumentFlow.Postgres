CREATE TYPE public.price_setting_method AS ENUM (
	'average',
	'dictionary',
	'manual',
	'is_giving'
);

ALTER TYPE public.price_setting_method OWNER TO postgres;
