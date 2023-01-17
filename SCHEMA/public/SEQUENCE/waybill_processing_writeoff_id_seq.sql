CREATE SEQUENCE public.waybill_processing_writeoff_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.waybill_processing_writeoff_id_seq OWNER TO postgres;

GRANT ALL ON SEQUENCE public.waybill_processing_writeoff_id_seq TO users;

ALTER SEQUENCE public.waybill_processing_writeoff_id_seq
	OWNED BY public.waybill_processing_writeoff.id;
