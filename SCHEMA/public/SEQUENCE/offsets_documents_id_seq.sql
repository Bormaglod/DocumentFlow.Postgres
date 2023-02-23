CREATE SEQUENCE public.offsets_documents_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.offsets_documents_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.offsets_documents_id_seq TO users;

ALTER SEQUENCE public.offsets_documents_id_seq
	OWNED BY public.offsets_documents.id;
