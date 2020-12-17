CREATE TABLE public.document (
	doc_date timestamp(0) with time zone NOT NULL,
	doc_year integer NOT NULL,
	doc_number character varying(25) NOT NULL,
	organization_id uuid
)
INHERITS (public.document_info);

ALTER TABLE ONLY public.document ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.document OWNER TO postgres;

GRANT ALL ON TABLE public.document TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.document TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.document
	ADD CONSTRAINT pk_document_id PRIMARY KEY (id);
