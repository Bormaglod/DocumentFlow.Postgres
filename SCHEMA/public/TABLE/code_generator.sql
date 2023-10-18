CREATE TABLE public.code_generator (
	id integer DEFAULT nextval('public.code_generator_id_seq'::regclass) NOT NULL,
	code_id smallint NOT NULL,
	parent_id integer,
	code_info_value public.code_info NOT NULL,
	code_name character varying(100) NOT NULL
);

ALTER TABLE public.code_generator OWNER TO postgres;

GRANT SELECT ON TABLE public.code_generator TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.code_generator
	ADD CONSTRAINT pk_code_generator_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.code_generator
	ADD CONSTRAINT unq_code_value UNIQUE (code_info_value, code_id, parent_id);

--------------------------------------------------------------------------------

ALTER TABLE public.code_generator
	ADD CONSTRAINT fk_code_generator_parent FOREIGN KEY (parent_id) REFERENCES public.code_generator(id) ON UPDATE CASCADE ON DELETE CASCADE;
