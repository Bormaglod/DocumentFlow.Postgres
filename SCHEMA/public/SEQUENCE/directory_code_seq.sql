CREATE SEQUENCE public.directory_code_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.directory_code_seq OWNER TO postgres;

GRANT USAGE ON SEQUENCE public.directory_code_seq TO users;
GRANT ALL ON SEQUENCE public.directory_code_seq TO admins;
