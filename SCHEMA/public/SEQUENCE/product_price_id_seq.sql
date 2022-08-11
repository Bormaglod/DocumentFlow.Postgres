CREATE SEQUENCE public.product_price_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.product_price_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.product_price_id_seq TO users;

ALTER SEQUENCE public.product_price_id_seq
	OWNED BY public.product_price.id;
