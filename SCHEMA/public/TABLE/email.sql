CREATE TABLE public.email (
	id bigint DEFAULT nextval('public.email_id_seq'::regclass) NOT NULL,
	address character varying(250),
	host character varying(150),
	port smallint,
	password character varying(20),
	signature_plain text,
	signature_html text
);

ALTER TABLE public.email OWNER TO postgres;

GRANT ALL ON TABLE public.email TO admins;
GRANT SELECT ON TABLE public.email TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.email
	ADD CONSTRAINT email_pkey PRIMARY KEY (id);
