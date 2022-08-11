CREATE TABLE public.model (
	id integer DEFAULT nextval('public.model_id_seq'::regclass) NOT NULL,
	manufacturer_id smallint,
	model_index smallint,
	name_model character varying(100)
);

ALTER TABLE public.model OWNER TO postgres;

GRANT SELECT ON TABLE public.model TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.model
	ADD CONSTRAINT fk_model_manufacturer FOREIGN KEY (manufacturer_id) REFERENCES public.manufacturer(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.model
	ADD CONSTRAINT unq_model_model UNIQUE (manufacturer_id, model_index);

--------------------------------------------------------------------------------

ALTER TABLE public.model
	ADD CONSTRAINT pk_model_id PRIMARY KEY (id);
