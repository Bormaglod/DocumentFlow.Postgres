CREATE TABLE public.directory (
	code character varying(30) NOT NULL,
	item_name character varying(255),
	parent_id uuid,
	is_folder boolean DEFAULT false NOT NULL
)
INHERITS (public.document_info);

ALTER TABLE ONLY public.directory ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.directory ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.directory OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.directory TO users;
GRANT SELECT ON TABLE public.directory TO managers;

COMMENT ON TABLE public.directory IS 'Основа для создания справочника';

COMMENT ON COLUMN public.directory.date_created IS 'Дата создания';

COMMENT ON COLUMN public.directory.date_updated IS 'Дата изменения';

COMMENT ON COLUMN public.directory.owner_id IS 'Владелец элемента справочника';

COMMENT ON COLUMN public.directory.user_created_id IS 'Пользователь создавший элемент справочника';

COMMENT ON COLUMN public.directory.user_updated_id IS 'Пользователь изменивший элемент справочника';

--------------------------------------------------------------------------------

ALTER TABLE public.directory
	ADD CONSTRAINT pk_directory_id PRIMARY KEY (id);
