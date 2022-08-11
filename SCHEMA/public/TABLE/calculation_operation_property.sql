CREATE TABLE public.calculation_operation_property (
	id bigint DEFAULT nextval('public.calculation_operation_property_id_seq'::regclass) NOT NULL,
	operation_id uuid NOT NULL,
	property_id uuid NOT NULL,
	property_value character varying(255)
);

ALTER TABLE public.calculation_operation_property OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calculation_operation_property TO users;
GRANT SELECT ON TABLE public.calculation_operation_property TO managers;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation_property
	ADD CONSTRAINT pk_calculation_operation_property_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation_property
	ADD CONSTRAINT unq_calculation_operation_property_op UNIQUE (operation_id, property_id);

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation_property
	ADD CONSTRAINT fk_calculation_operation_property FOREIGN KEY (property_id) REFERENCES public.property(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation_property
	ADD CONSTRAINT fk_calculation_operation_property_op FOREIGN KEY (operation_id) REFERENCES public.calculation_operation(id) ON UPDATE CASCADE ON DELETE CASCADE;
