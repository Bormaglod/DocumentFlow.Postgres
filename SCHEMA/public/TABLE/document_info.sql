CREATE TABLE public.document_info (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	owner_id uuid,
	user_created_id uuid NOT NULL,
	date_created timestamp with time zone NOT NULL,
	user_updated_id uuid NOT NULL,
	date_updated timestamp with time zone NOT NULL,
	deleted boolean DEFAULT false NOT NULL
);

ALTER TABLE public.document_info OWNER TO postgres;

GRANT SELECT ON TABLE public.document_info TO users;
GRANT SELECT ON TABLE public.document_info TO managers;

COMMENT ON TABLE public.document_info IS 'Базовый документ являющийся основой для справочников и любых жругих документов';

COMMENT ON COLUMN public.document_info.owner_id IS 'Владелец документа';

COMMENT ON COLUMN public.document_info.user_created_id IS 'Пользователь создавший документ';

COMMENT ON COLUMN public.document_info.date_created IS 'Дата создания документа';

COMMENT ON COLUMN public.document_info.user_updated_id IS 'Пользователь изменивший документ';

COMMENT ON COLUMN public.document_info.date_updated IS 'Дата изменения документа';

--------------------------------------------------------------------------------

ALTER TABLE public.document_info
	ADD CONSTRAINT pk_document_info_id PRIMARY KEY (id);
