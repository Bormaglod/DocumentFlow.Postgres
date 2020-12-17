CREATE TABLE public.entity_kind (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	code character varying(255) NOT NULL,
	name character varying(40),
	title character varying(255),
	has_group boolean DEFAULT false NOT NULL,
	transition_id uuid NOT NULL
);

ALTER TABLE public.entity_kind OWNER TO postgres;

GRANT ALL ON TABLE public.entity_kind TO admins;
GRANT SELECT ON TABLE public.entity_kind TO users;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.entity_kind TO designers;

COMMENT ON TABLE public.entity_kind IS 'Таблицы доступные для просмотра и редактирования';

COMMENT ON COLUMN public.entity_kind.code IS 'Уникальный текстовый код документа';

COMMENT ON COLUMN public.entity_kind.name IS 'Сокращенное наименование документа/справочника';

COMMENT ON COLUMN public.entity_kind.title IS 'Полное наименование документа/справочника';

--------------------------------------------------------------------------------

ALTER TABLE public.entity_kind
	ADD CONSTRAINT pk_entity_kind_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.entity_kind
	ADD CONSTRAINT fk_entity_kind_transition FOREIGN KEY (transition_id) REFERENCES public.transition(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.entity_kind
	ADD CONSTRAINT unq_entity_kind_code UNIQUE (code);
