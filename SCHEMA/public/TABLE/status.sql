CREATE TABLE public.status (
	id integer NOT NULL,
	code character varying(80) NOT NULL,
	note character varying(255),
	picture_id uuid
);

ALTER TABLE public.status OWNER TO postgres;

GRANT ALL ON TABLE public.status TO admins;
GRANT SELECT ON TABLE public.status TO users;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.status TO designers;

COMMENT ON TABLE public.status IS 'Состояния документов/справочников';

COMMENT ON COLUMN public.status.code IS 'Наименование состояния';

COMMENT ON COLUMN public.status.note IS 'Полное описание состояния документа/справочника';

--------------------------------------------------------------------------------

ALTER TABLE public.status
	ADD CONSTRAINT pk_status_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.status
	ADD CONSTRAINT fk_status_picture FOREIGN KEY (picture_id) REFERENCES public.picture(id) ON UPDATE CASCADE ON DELETE SET NULL;
