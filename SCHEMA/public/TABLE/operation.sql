CREATE TABLE public.operation (
	produced integer,
	prod_time integer,
	production_rate integer,
	type_id uuid,
	salary numeric(15,2),
	length integer,
	left_cleaning numeric(4,1),
	left_sweep integer,
	right_cleaning numeric(4,1),
	right_sweep integer,
	program integer,
	measurement_id uuid
)
INHERITS (public.directory);

ALTER TABLE ONLY public.operation ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.operation OWNER TO postgres;

GRANT ALL ON TABLE public.operation TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation TO users;

COMMENT ON COLUMN public.operation.produced IS 'Выработка за время [prod_time], шт.';

COMMENT ON COLUMN public.operation.prod_time IS 'Время за которое было произведено [produced] операций, мин';

COMMENT ON COLUMN public.operation.production_rate IS 'Норма выработки, шт./час';

COMMENT ON COLUMN public.operation.type_id IS 'Тип операции';

COMMENT ON COLUMN public.operation.salary IS 'Плата за выполнение 1 ед. операции';

COMMENT ON COLUMN public.operation.length IS 'РЕЗКА: Длина провода';

COMMENT ON COLUMN public.operation.left_cleaning IS 'РЕЗКА:  Длина зачистки с начала провода';

COMMENT ON COLUMN public.operation.left_sweep IS 'РЕЗКА: Ширина окна на которое снимается изоляция в начале провода';

COMMENT ON COLUMN public.operation.right_cleaning IS 'РЕЗКА: Длина зачистки с конца провода';

COMMENT ON COLUMN public.operation.right_sweep IS 'РЕЗКА: Ширина окна на которое снимается изоляция в конце провода';

COMMENT ON COLUMN public.operation.program IS 'РЕЗКА: Ноиер программы';

--------------------------------------------------------------------------------

CREATE TRIGGER operation_ad
	AFTER DELETE ON public.operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER operation_aiu
	AFTER INSERT OR UPDATE ON public.operation
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_bi
	BEFORE INSERT ON public.operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_bu
	BEFORE UPDATE ON public.operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_bu_status
	BEFORE UPDATE ON public.operation
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_operation();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_au_archive
	AFTER UPDATE ON public.operation
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.send_price_to_archive();

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
	ADD CONSTRAINT fk_operation_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT fk_operation_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT fk_operation_parent FOREIGN KEY (parent_id) REFERENCES public.operation(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT fk_operation_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT fk_operation_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT fk_operation_type FOREIGN KEY (type_id) REFERENCES public.operation_type(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation
	ADD CONSTRAINT fk_operation_measurement FOREIGN KEY (measurement_id) REFERENCES public.measurement(id) ON UPDATE CASCADE ON DELETE SET NULL;
