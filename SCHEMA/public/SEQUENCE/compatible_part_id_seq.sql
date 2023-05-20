CREATE SEQUENCE public.compatible_part_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.compatible_part_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.compatible_part_id_seq TO users;

ALTER SEQUENCE public.compatible_part_id_seq
	OWNED BY public.compatible_part.id;
