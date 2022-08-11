CREATE TABLE public.operation_type (
	salary numeric(15,2) NOT NULL
)
INHERITS (public.directory);

ALTER TABLE ONLY public.operation_type ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.operation_type ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.operation_type ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.operation_type OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_type TO users;

COMMENT ON TABLE public.operation_type IS 'Основные типы производственных операций';

COMMENT ON COLUMN public.operation_type.salary IS 'Базовая часовая ставка при расчёте заработной платы';

--------------------------------------------------------------------------------

CREATE TRIGGER operation_type_ad
	AFTER DELETE ON public.operation_type
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER operation_type_aiu
	AFTER INSERT OR UPDATE ON public.operation_type
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_type_aiu_0
	AFTER INSERT OR UPDATE ON public.operation_type
	FOR EACH ROW
	EXECUTE PROCEDURE public.operation_type_changed();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_type_bi
	BEFORE INSERT ON public.operation_type
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_type_bu
	BEFORE UPDATE ON public.operation_type
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT operation_type_check CHECK ((salary > (0)::numeric));

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT pk_operation_type_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT unq_operation_type_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT fk_operation_type_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT fk_operation_type_parent FOREIGN KEY (parent_id) REFERENCES public.operation_type(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT fk_operation_type_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
