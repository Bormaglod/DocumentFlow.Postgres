CREATE SEQUENCE public.return_materials_rows_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.return_materials_rows_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.return_materials_rows_id_seq TO users;

ALTER SEQUENCE public.return_materials_rows_id_seq
	OWNED BY public.return_materials_rows.id;
