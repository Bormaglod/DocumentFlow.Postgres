CREATE TABLE public.property (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	property_name character varying(50) NOT NULL,
	title character varying(50)
);

ALTER TABLE public.property OWNER TO postgres;

GRANT SELECT ON TABLE public.property TO users;
GRANT SELECT ON TABLE public.property TO managers;

COMMENT ON TABLE public.property IS 'Список дополнительных свойст/параметров производственных операций';

--------------------------------------------------------------------------------

ALTER TABLE public.property
	ADD CONSTRAINT pk_parameters_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.property
	ADD CONSTRAINT unq_parameters_name UNIQUE (property_name);
