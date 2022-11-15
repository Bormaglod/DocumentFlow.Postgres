CREATE TABLE public.document_type (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	code character varying(30) NOT NULL,
	document_name character varying(250),
	account_avg boolean
);

ALTER TABLE public.document_type OWNER TO postgres;

GRANT SELECT ON TABLE public.document_type TO users;

COMMENT ON COLUMN public.document_type.account_avg IS 'Учитывать при расчёте средней цены';

--------------------------------------------------------------------------------

ALTER TABLE public.document_type
	ADD CONSTRAINT pk_document_type_id PRIMARY KEY (id);
