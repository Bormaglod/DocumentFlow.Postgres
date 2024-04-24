CREATE TABLE public.schema_states (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	document_type_id uuid NOT NULL,
	starting_id smallint NOT NULL,
	finishing_id smallint,
	deleted_ids smallint[]
);

ALTER TABLE public.schema_states OWNER TO postgres;

GRANT ALL ON TABLE public.schema_states TO admins;
GRANT SELECT ON TABLE public.schema_states TO managers;
GRANT SELECT ON TABLE public.schema_states TO users;

COMMENT ON TABLE public.schema_states IS 'Схемы состояний документов';

COMMENT ON COLUMN public.schema_states.document_type_id IS 'Тип документа для которого предназначена схема';

COMMENT ON COLUMN public.schema_states.starting_id IS 'Начальное состояние документа';

COMMENT ON COLUMN public.schema_states.finishing_id IS 'Конечное состояние документа';

COMMENT ON COLUMN public.schema_states.deleted_ids IS 'Список состояний документа в которых возможно удаление документа (кроме начального)';

--------------------------------------------------------------------------------

ALTER TABLE public.schema_states
	ADD CONSTRAINT fk_schema_states_document_type FOREIGN KEY (document_type_id) REFERENCES public.document_type(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.schema_states
	ADD CONSTRAINT fk_schema_states_state_finishing FOREIGN KEY (finishing_id) REFERENCES public.state(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.schema_states
	ADD CONSTRAINT fk_schema_states_state_starting FOREIGN KEY (starting_id) REFERENCES public.state(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.schema_states
	ADD CONSTRAINT pk_schema_states PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.schema_states
	ADD CONSTRAINT unq_schema_states_doc UNIQUE (document_type_id);
