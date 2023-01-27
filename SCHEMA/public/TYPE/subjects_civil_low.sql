CREATE TYPE public.subjects_civil_low AS ENUM (
	'person',
	'legal entity'
);

ALTER TYPE public.subjects_civil_low OWNER TO postgres;
