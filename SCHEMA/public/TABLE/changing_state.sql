CREATE TABLE public.changing_state (
	id bigint DEFAULT nextval('public.changing_state_id_seq'::regclass) NOT NULL,
	name_change character varying(50) NOT NULL,
	schema_id uuid NOT NULL,
	from_state_id smallint NOT NULL,
	to_state_id smallint NOT NULL
);

ALTER TABLE public.changing_state OWNER TO postgres;

GRANT ALL ON TABLE public.changing_state TO admins;
GRANT SELECT ON TABLE public.changing_state TO managers;
GRANT SELECT ON TABLE public.changing_state TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.changing_state
	ADD CONSTRAINT fk_changing_state_from FOREIGN KEY (from_state_id) REFERENCES public.state(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.changing_state
	ADD CONSTRAINT fk_changing_state_schema_states FOREIGN KEY (schema_id) REFERENCES public.schema_states(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.changing_state
	ADD CONSTRAINT fk_changing_state_state_to FOREIGN KEY (to_state_id) REFERENCES public.state(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.changing_state
	ADD CONSTRAINT pk_changing_state_id PRIMARY KEY (id);
