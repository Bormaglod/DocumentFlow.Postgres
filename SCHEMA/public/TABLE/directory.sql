CREATE TABLE public.directory (
	code character varying(25) NOT NULL,
	name character varying(255),
	parent_id uuid
)
INHERITS (public.document_info);

ALTER TABLE ONLY public.directory ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.directory OWNER TO postgres;

GRANT ALL ON TABLE public.directory TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directory TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.directory
	ADD CONSTRAINT pk_directory_id PRIMARY KEY (id);
