CREATE SEQUENCE public.print_kind_form_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.print_kind_form_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.print_kind_form_id_seq TO admins;
GRANT SELECT ON SEQUENCE public.print_kind_form_id_seq TO users;

ALTER SEQUENCE public.print_kind_form_id_seq
	OWNED BY public.print_kind_form.id;
