CREATE SEQUENCE public.email_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.email_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.email_id_seq TO admins;
GRANT SELECT ON SEQUENCE public.email_id_seq TO users;

ALTER SEQUENCE public.email_id_seq
	OWNED BY public.email.id;
