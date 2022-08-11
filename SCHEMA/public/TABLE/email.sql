CREATE TABLE public.email (
	id bigint DEFAULT nextval('public.email_id_seq'::regclass) NOT NULL,
	address character varying(250),
	mail_host character varying(150),
	mail_port smallint,
	user_password character varying(20),
	signature_plain text,
	signature_html text
);

ALTER TABLE public.email OWNER TO postgres;

GRANT SELECT ON TABLE public.email TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.email
	ADD CONSTRAINT pk_email_id PRIMARY KEY (id);
