CREATE SEQUENCE public.operation_goods_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.operation_goods_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.operation_goods_id_seq TO users;

ALTER SEQUENCE public.operation_goods_id_seq
	OWNED BY public.operation_goods.id;
