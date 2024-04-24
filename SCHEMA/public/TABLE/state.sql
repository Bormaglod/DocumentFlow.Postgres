CREATE TABLE public.state (
	id smallint NOT NULL,
	code character varying(80) NOT NULL,
	state_name character varying(50) NOT NULL,
	note text
);

ALTER TABLE public.state OWNER TO postgres;

GRANT SELECT ON TABLE public.state TO users;
GRANT ALL ON TABLE public.state TO admins;
GRANT SELECT ON TABLE public.state TO managers;

COMMENT ON TABLE public.state IS 'Состояния документов';

COMMENT ON COLUMN public.state.code IS 'Код состояния';

COMMENT ON COLUMN public.state.state_name IS 'Наименование состояния документа';

COMMENT ON COLUMN public.state.note IS 'Полное описание состояния документа';

--------------------------------------------------------------------------------

ALTER TABLE public.state
	ADD CONSTRAINT pk_state_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.state
	ADD CONSTRAINT unq_state_code UNIQUE (code);
