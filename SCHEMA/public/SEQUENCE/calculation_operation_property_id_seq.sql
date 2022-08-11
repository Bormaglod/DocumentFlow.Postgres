CREATE SEQUENCE public.calculation_operation_property_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.calculation_operation_property_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.calculation_operation_property_id_seq TO users;

ALTER SEQUENCE public.calculation_operation_property_id_seq
	OWNED BY public.calculation_operation_property.id;
