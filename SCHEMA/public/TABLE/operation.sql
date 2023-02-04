CREATE TABLE public.operation (
	produced integer,
	prod_time integer,
	production_rate integer,
	type_id uuid,
	salary numeric(15,4) DEFAULT 0,
	manual_input boolean,
	date_norm date
)
INHERITS (public.directory);

ALTER TABLE ONLY public.operation ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.operation ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.operation ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.operation OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation TO users;

COMMENT ON TABLE public.operation IS 'Оборудование';

COMMENT ON COLUMN public.operation.produced IS 'Выработка за время [prod_time], шт.';

COMMENT ON COLUMN public.operation.prod_time IS 'Время за которое было произведено [produced] операций, мин';

COMMENT ON COLUMN public.operation.production_rate IS 'Норма выработки, шт./час';

COMMENT ON COLUMN public.operation.type_id IS 'Тип операции';

COMMENT ON COLUMN public.operation.salary IS 'Плата за выполнение ед. операции';

COMMENT ON COLUMN public.operation.date_norm IS 'Дата нормирования';

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER operation_aiu
	AFTER INSERT OR UPDATE ON public.operation
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER operation_aiu_0
	AFTER INSERT OR UPDATE ON public.operation
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.operation_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_bi
	BEFORE INSERT ON public.operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_biu_0
	BEFORE INSERT OR UPDATE ON public.operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.operation_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_bu
	BEFORE UPDATE ON public.operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_ad_0
	AFTER DELETE ON public.operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_ad_1
	AFTER DELETE ON public.operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.operation_deleted();

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT pk_operation_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT unq_operation_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT fk_operation_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT fk_operation_parent FOREIGN KEY (parent_id) REFERENCES public.operation(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT fk_operation_type FOREIGN KEY (type_id) REFERENCES public.operation_type(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT fk_operation_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
