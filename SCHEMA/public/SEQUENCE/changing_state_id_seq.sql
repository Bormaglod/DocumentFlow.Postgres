CREATE SEQUENCE public.changing_state_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.changing_state_id_seq OWNER TO postgres;

GRANT SELECT ON SEQUENCE public.changing_state_id_seq TO users;
GRANT SELECT ON SEQUENCE public.changing_state_id_seq TO designers;

ALTER SEQUENCE public.changing_state_id_seq
	OWNED BY public.changing_state.id;
