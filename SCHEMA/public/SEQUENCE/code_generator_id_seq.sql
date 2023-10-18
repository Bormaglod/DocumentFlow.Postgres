CREATE SEQUENCE public.code_generator_id_seq
	AS integer
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.code_generator_id_seq OWNER TO postgres;

GRANT SELECT ON SEQUENCE public.code_generator_id_seq TO users;

ALTER SEQUENCE public.code_generator_id_seq
	OWNED BY public.code_generator.id;
