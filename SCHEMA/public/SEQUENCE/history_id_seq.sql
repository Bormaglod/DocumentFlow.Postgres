CREATE SEQUENCE public.history_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.history_id_seq OWNER TO postgres;

GRANT USAGE ON SEQUENCE public.history_id_seq TO users;
GRANT ALL ON SEQUENCE public.history_id_seq TO admins;

ALTER SEQUENCE public.history_id_seq
	OWNED BY public.history.id;
