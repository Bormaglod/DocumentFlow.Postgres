CREATE TABLE public.calculation_cutting (
)
INHERITS (public.calculation_operation);

ALTER TABLE ONLY public.calculation_cutting ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.calculation_cutting ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.calculation_cutting ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.calculation_cutting ALTER COLUMN item_cost SET DEFAULT 0;

ALTER TABLE ONLY public.calculation_cutting ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE ONLY public.calculation_cutting ALTER COLUMN repeats SET DEFAULT 1;

ALTER TABLE public.calculation_cutting OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calculation_cutting TO users;

COMMENT ON TABLE public.calculation_cutting IS 'Список операций резки в калькуляции';

COMMENT ON COLUMN public.calculation_cutting.code IS 'Код операции';

COMMENT ON COLUMN public.calculation_cutting.equipment_id IS 'Используемое оборудование';

COMMENT ON COLUMN public.calculation_cutting.item_cost IS 'Стоимость операции с учетом повторов операции на ед. изм. калькуляции';

COMMENT ON COLUMN public.calculation_cutting.item_id IS 'Операция (только резка) (cutting)';

COMMENT ON COLUMN public.calculation_cutting.item_name IS 'Наименование операции';

COMMENT ON COLUMN public.calculation_cutting.material_amount IS 'Количество используемого материала на 1 операцию (в ед. изм. этой операции)';

COMMENT ON COLUMN public.calculation_cutting.material_id IS 'Используемый материал';

COMMENT ON COLUMN public.calculation_cutting.owner_id IS 'Калькуляция';

COMMENT ON COLUMN public.calculation_cutting.price IS 'Расценка на операцию на ед. изм. операции';

COMMENT ON COLUMN public.calculation_cutting.repeats IS 'Количество повторов операции';

COMMENT ON COLUMN public.calculation_cutting.tools_id IS 'Используемый инструмент';

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_cutting_ad
	AFTER DELETE ON public.calculation_cutting
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_cutting_aiu
	AFTER INSERT OR UPDATE ON public.calculation_cutting
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_cutting_bi
	BEFORE INSERT ON public.calculation_cutting
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_cutting_bu
	BEFORE UPDATE ON public.calculation_cutting
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_cutting_biu_0
	BEFORE INSERT OR UPDATE ON public.calculation_cutting
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_operation_changing();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_cutting_aiu_0
	AFTER INSERT OR UPDATE ON public.calculation_cutting
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_operation_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_cutting_aiu_1
	AFTER INSERT OR UPDATE ON public.calculation_cutting
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_operation_changed();

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_cutting
	ADD CONSTRAINT pk_calculation_cutting_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_cutting
	ADD CONSTRAINT unq_calculation_cutting_code UNIQUE (owner_id, code);

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_cutting
	ADD CONSTRAINT fk_calculation_cutting_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_cutting
	ADD CONSTRAINT fk_calculation_cutting_item FOREIGN KEY (item_id) REFERENCES public.cutting(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_cutting
	ADD CONSTRAINT fk_calculation_cutting_owner FOREIGN KEY (owner_id) REFERENCES public.calculation(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_cutting
	ADD CONSTRAINT fk_calculation_cutting_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_cutting
	ADD CONSTRAINT fk_calculation_cutting_equipment FOREIGN KEY (equipment_id) REFERENCES public.equipment(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_cutting
	ADD CONSTRAINT fk_calculation_cutting_tools FOREIGN KEY (tools_id) REFERENCES public.equipment(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_cutting
	ADD CONSTRAINT fk_calculation_cutting_material FOREIGN KEY (material_id) REFERENCES public.material(id) ON UPDATE CASCADE;
