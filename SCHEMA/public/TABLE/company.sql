CREATE TABLE public.company (
	full_name character varying(150),
	inn numeric(12,0),
	kpp numeric(9,0),
	ogrn numeric(13,0),
	okpo numeric(8,0),
	okopf_id uuid,
	account_id uuid
)
INHERITS (public.directory);

ALTER TABLE ONLY public.company ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.company ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.company ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.company OWNER TO postgres;

GRANT SELECT ON TABLE public.company TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.company
	ADD CONSTRAINT pk_company_id PRIMARY KEY (id);
