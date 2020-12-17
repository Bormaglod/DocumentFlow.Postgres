CREATE TYPE public.document_direction AS ENUM (
	'income',
	'expense'
);

ALTER TYPE public.document_direction OWNER TO postgres;
