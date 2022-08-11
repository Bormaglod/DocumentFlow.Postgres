CREATE TABLE public.document_type (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	code character varying(30) NOT NULL,
	document_name character varying(250)
);

ALTER TABLE public.document_type OWNER TO postgres;

GRANT SELECT ON TABLE public.document_type TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.document_type
	ADD CONSTRAINT pk_document_type_id PRIMARY KEY (id);
