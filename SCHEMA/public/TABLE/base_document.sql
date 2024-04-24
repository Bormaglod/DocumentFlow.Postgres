CREATE TABLE public.base_document (
	organization_id uuid NOT NULL,
	document_date timestamp(0) with time zone NOT NULL,
	document_number integer NOT NULL,
	state_id smallint DEFAULT 0 NOT NULL
)
INHERITS (public.document_info);

ALTER TABLE ONLY public.base_document ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.base_document ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.base_document OWNER TO postgres;

GRANT SELECT ON TABLE public.base_document TO users;

COMMENT ON TABLE public.base_document IS 'Основа для создания документов';

COMMENT ON COLUMN public.base_document.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.base_document.document_number IS 'Порядковый номер документа';

--------------------------------------------------------------------------------

ALTER TABLE public.base_document
	ADD CONSTRAINT pk_base_document_id PRIMARY KEY (id);
