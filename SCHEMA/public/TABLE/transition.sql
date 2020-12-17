CREATE TABLE public.transition (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	name character varying(100) NOT NULL,
	starting_id integer DEFAULT 0 NOT NULL,
	finishing_id integer,
	deleted_ids integer[],
	diagram_model bytea
);

ALTER TABLE public.transition OWNER TO postgres;

GRANT ALL ON TABLE public.transition TO admins;
GRANT SELECT ON TABLE public.transition TO users;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.transition TO designers;

COMMENT ON COLUMN public.transition.starting_id IS 'Начальное состояние документа';

COMMENT ON COLUMN public.transition.finishing_id IS 'Конечное состояние документа';

COMMENT ON COLUMN public.transition.deleted_ids IS 'Список состояний документа в которых возможно удаление документа (кроме начального)';

--------------------------------------------------------------------------------

ALTER TABLE public.transition
	ADD CONSTRAINT pk_transition_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.transition
	ADD CONSTRAINT unq_transition_name UNIQUE (name);

--------------------------------------------------------------------------------

ALTER TABLE public.transition
	ADD CONSTRAINT fk_transition_finishing FOREIGN KEY (finishing_id) REFERENCES public.status(id) ON UPDATE SET NULL ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.transition
	ADD CONSTRAINT fk_transition_starting FOREIGN KEY (starting_id) REFERENCES public.status(id) ON UPDATE CASCADE ON DELETE CASCADE;
