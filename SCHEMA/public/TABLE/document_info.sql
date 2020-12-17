CREATE TABLE public.document_info (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	status_id integer NOT NULL,
	owner_id uuid,
	entity_kind_id uuid NOT NULL,
	user_created_id uuid NOT NULL,
	date_created timestamp with time zone NOT NULL,
	user_updated_id uuid NOT NULL,
	date_updated timestamp with time zone NOT NULL,
	user_locked_id uuid,
	date_locked timestamp with time zone
);

ALTER TABLE public.document_info OWNER TO postgres;

GRANT ALL ON TABLE public.document_info TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.document_info TO users;

COMMENT ON COLUMN public.document_info.status_id IS 'Текущее состояние документа';

COMMENT ON COLUMN public.document_info.owner_id IS 'Владелец текущего документа';

COMMENT ON COLUMN public.document_info.user_created_id IS 'Пользователь создавший документ';

COMMENT ON COLUMN public.document_info.date_created IS 'Дата создания документа';

COMMENT ON COLUMN public.document_info.user_updated_id IS 'Пользователь изменивший документ документ';

COMMENT ON COLUMN public.document_info.date_updated IS 'Дата изменения документа';

COMMENT ON COLUMN public.document_info.user_locked_id IS 'Пользователь заблокировавший документ';

COMMENT ON COLUMN public.document_info.date_locked IS 'Дата блокирования документа';

--------------------------------------------------------------------------------

ALTER TABLE public.document_info
	ADD CONSTRAINT pk_document_info_id PRIMARY KEY (id);
