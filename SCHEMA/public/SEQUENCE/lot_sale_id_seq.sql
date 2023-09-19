CREATE SEQUENCE public.lot_sale_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.lot_sale_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.lot_sale_id_seq TO users;

ALTER SEQUENCE public.lot_sale_id_seq
	OWNED BY public.lot_sale.id;
