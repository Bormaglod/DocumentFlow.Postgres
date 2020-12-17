CREATE TABLE public.user_alias (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	name character varying(20) NOT NULL,
	pg_name character varying(80) NOT NULL,
	surname character varying(40),
	first_name character varying(20),
	middle_name character varying(40),
	password character varying(16),
	token text,
	is_system boolean DEFAULT false NOT NULL
);

ALTER TABLE public.user_alias OWNER TO postgres;

GRANT ALL ON TABLE public.user_alias TO admins;
GRANT SELECT ON TABLE public.user_alias TO users;
GRANT SELECT ON TABLE public.user_alias TO guest;

GRANT UPDATE(token) ON TABLE public.user_alias TO users;

COMMENT ON TABLE public.user_alias IS 'Пользователи';

COMMENT ON COLUMN public.user_alias.name IS 'Пользователь';

COMMENT ON COLUMN public.user_alias.pg_name IS 'Имя пользователя в Postgres';

COMMENT ON COLUMN public.user_alias.surname IS 'Фамилия';

COMMENT ON COLUMN public.user_alias.first_name IS 'Имя';

COMMENT ON COLUMN public.user_alias.middle_name IS 'Отчество';

--------------------------------------------------------------------------------

ALTER TABLE public.user_alias
	ADD CONSTRAINT pk_user_alias_id PRIMARY KEY (id);
