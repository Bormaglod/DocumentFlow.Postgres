CREATE SEQUENCE public.price_approval_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.price_approval_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.price_approval_id_seq TO users;

ALTER SEQUENCE public.price_approval_id_seq
	OWNED BY public.price_approval.id;
