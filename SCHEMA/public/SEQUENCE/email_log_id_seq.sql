CREATE SEQUENCE public.email_log_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.email_log_id_seq OWNER TO postgres;

ALTER SEQUENCE public.email_log_id_seq
	OWNED BY public.email_log.id;
