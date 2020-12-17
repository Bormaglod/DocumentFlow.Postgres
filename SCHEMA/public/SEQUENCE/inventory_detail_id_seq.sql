CREATE SEQUENCE public.inventory_detail_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.inventory_detail_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.inventory_detail_id_seq TO admins;
GRANT USAGE ON SEQUENCE public.inventory_detail_id_seq TO users;

ALTER SEQUENCE public.inventory_detail_id_seq
	OWNED BY public.inventory_detail.id;
