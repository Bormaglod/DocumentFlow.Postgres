CREATE TABLE public.calculation_operation (
	equipment_id uuid,
	tools_id uuid,
	material_id uuid,
	material_amount numeric(12,3),
	repeats integer DEFAULT 1,
	previous_operation character varying[],
	note text,
	stimul_cost numeric(15,2),
	preview bytea
)
INHERITS (public.calculation_item);

ALTER TABLE ONLY public.calculation_operation ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.calculation_operation ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.calculation_operation ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.calculation_operation ALTER COLUMN item_cost SET DEFAULT 0;

ALTER TABLE ONLY public.calculation_operation ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE public.calculation_operation OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calculation_operation TO users;

COMMENT ON TABLE public.calculation_operation IS 'Список производственных операция в калькуляции';

COMMENT ON COLUMN public.calculation_operation.code IS 'Код операции';

COMMENT ON COLUMN public.calculation_operation.item_cost IS 'Стоимость операции с учетом повторов операции';

COMMENT ON COLUMN public.calculation_operation.item_id IS 'Операция (кроме резки) (operation)';

COMMENT ON COLUMN public.calculation_operation.item_name IS 'Наименование операции';

COMMENT ON COLUMN public.calculation_operation.owner_id IS 'Калькуляция';

COMMENT ON COLUMN public.calculation_operation.price IS 'Расценка на операцию на ед. изм.';

COMMENT ON COLUMN public.calculation_operation.equipment_id IS 'Используемое оборудование';

COMMENT ON COLUMN public.calculation_operation.tools_id IS 'Используемый инструмент';

COMMENT ON COLUMN public.calculation_operation.material_id IS 'Используемый материал';

COMMENT ON COLUMN public.calculation_operation.material_amount IS 'Количество используемого материала на 1 опер. (в ед. изм. этой операции)';

COMMENT ON COLUMN public.calculation_operation.repeats IS 'Количество повторов операции';

COMMENT ON COLUMN public.calculation_operation.previous_operation IS 'Список кодов операций результат которых используется в текущей';

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_operation_ad
	AFTER DELETE ON public.calculation_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_operation_aiu
	AFTER INSERT OR UPDATE ON public.calculation_operation
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_operation_bi
	BEFORE INSERT ON public.calculation_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_operation_bu
	BEFORE UPDATE ON public.calculation_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_operation_aiu_0
	AFTER INSERT OR UPDATE ON public.calculation_operation
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_operation_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_operation_biu_0
	BEFORE INSERT OR UPDATE ON public.calculation_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_operation_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_operation_aiu_1
	AFTER INSERT OR UPDATE ON public.calculation_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_operation_changed();

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation
	ADD CONSTRAINT pk_calculation_operation_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation
	ADD CONSTRAINT unq_calculation_operation_code UNIQUE (owner_id, code);

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation
	ADD CONSTRAINT fk_calculation_operation_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation
	ADD CONSTRAINT fk_calculation_operation_item FOREIGN KEY (item_id) REFERENCES public.operation(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation
	ADD CONSTRAINT fk_calculation_operation_owner FOREIGN KEY (owner_id) REFERENCES public.calculation(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation
	ADD CONSTRAINT fk_calculation_operation_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation
	ADD CONSTRAINT fk_calculation_operation_equipment FOREIGN KEY (equipment_id) REFERENCES public.equipment(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation
	ADD CONSTRAINT fk_calculation_operation_tools FOREIGN KEY (tools_id) REFERENCES public.equipment(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_operation
	ADD CONSTRAINT fk_calculation_operation_material FOREIGN KEY (material_id) REFERENCES public.material(id) ON UPDATE CASCADE;
