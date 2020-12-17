CREATE TABLE public.document_refs (
	id bigint DEFAULT nextval('public.document_refs_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	file_name character varying(255) NOT NULL,
	note text,
	crc bigint,
	length bigint
);

ALTER TABLE public.document_refs OWNER TO postgres;

GRANT ALL ON TABLE public.document_refs TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.document_refs TO users;

--------------------------------------------------------------------------------

CREATE INDEX idx_document_refs_owner ON public.document_refs USING btree (owner_id);

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER document_refs_bi
	AFTER INSERT OR UPDATE ON public.document_refs
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.check_document_references();

--------------------------------------------------------------------------------

ALTER TABLE public.document_refs
	ADD CONSTRAINT pk_document_refs_id PRIMARY KEY (id);
