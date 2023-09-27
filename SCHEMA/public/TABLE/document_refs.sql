CREATE TABLE public.document_refs (
	id bigint DEFAULT nextval('public.document_refs_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	file_name character varying(255) NOT NULL,
	note text,
	file_length bigint,
	thumbnail text,
	s3object character varying(255)
);

ALTER TABLE public.document_refs OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.document_refs TO users;
GRANT SELECT ON TABLE public.document_refs TO managers;

COMMENT ON TABLE public.document_refs IS 'Файлы прикреплённые к документам';

COMMENT ON COLUMN public.document_refs.owner_id IS 'Документ к которому относится этот файл';

COMMENT ON COLUMN public.document_refs.file_name IS 'Наименование файла';

COMMENT ON COLUMN public.document_refs.note IS 'Описание содержимого файла';

COMMENT ON COLUMN public.document_refs.file_length IS 'Длина файла';

COMMENT ON COLUMN public.document_refs.thumbnail IS 'Уменьшенное изображение в формате base64';

--------------------------------------------------------------------------------

CREATE INDEX idx_document_refs_owner ON public.document_refs USING btree (owner_id);

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER document_refs_aiu
	AFTER INSERT OR UPDATE ON public.document_refs
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_refs_checking();

--------------------------------------------------------------------------------

ALTER TABLE public.document_refs
	ADD CONSTRAINT pk_document_refs_id PRIMARY KEY (id);
