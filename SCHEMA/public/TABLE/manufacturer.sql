CREATE TABLE public.manufacturer (
	id smallint NOT NULL,
	name_brand character varying(50)
);

ALTER TABLE public.manufacturer OWNER TO postgres;

GRANT SELECT ON TABLE public.manufacturer TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.manufacturer
	ADD CONSTRAINT pk_manufacturer_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.manufacturer
	ADD CONSTRAINT unq_manufacturer_name UNIQUE (name_brand);
