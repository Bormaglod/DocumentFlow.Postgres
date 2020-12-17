CREATE TABLE public.changing_status (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	name character varying(50) NOT NULL,
	transition_id uuid NOT NULL,
	from_status_id integer NOT NULL,
	to_status_id integer NOT NULL,
	picture_id uuid,
	order_index integer DEFAULT 0,
	is_system boolean DEFAULT false
);

ALTER TABLE public.changing_status OWNER TO postgres;

GRANT ALL ON TABLE public.changing_status TO admins;
GRANT SELECT ON TABLE public.changing_status TO users;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.changing_status TO designers;

--------------------------------------------------------------------------------

ALTER TABLE public.changing_status
	ADD CONSTRAINT chk_changing_status CHECK ((from_status_id <> to_status_id));

--------------------------------------------------------------------------------

ALTER TABLE public.changing_status
	ADD CONSTRAINT pk_changing_status PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.changing_status
	ADD CONSTRAINT unq_changing_status UNIQUE (transition_id, from_status_id, to_status_id);

--------------------------------------------------------------------------------

ALTER TABLE public.changing_status
	ADD CONSTRAINT fk_changing_status_from FOREIGN KEY (from_status_id) REFERENCES public.status(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.changing_status
	ADD CONSTRAINT fk_changing_status_picture FOREIGN KEY (picture_id) REFERENCES public.picture(id) ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.changing_status
	ADD CONSTRAINT fk_changing_status_to FOREIGN KEY (to_status_id) REFERENCES public.status(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.changing_status
	ADD CONSTRAINT fk_changing_status_transition FOREIGN KEY (transition_id) REFERENCES public.transition(id) ON DELETE CASCADE;
