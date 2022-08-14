CREATE SEQUENCE public.wage_previous_periods_id_seq
	START WITH 1
	INCREMENT BY 1
	NO MAXVALUE
	NO MINVALUE
	CACHE 1;

ALTER SEQUENCE public.wage_previous_periods_id_seq OWNER TO postgres;

ALTER SEQUENCE public.wage_previous_periods_id_seq
	OWNED BY public.wage_previous_periods.id;
