CREATE TABLE public.calculation_material (
	amount numeric(12,3) DEFAULT 0,
	price_method public.price_setting_method DEFAULT 'average'::public.price_setting_method NOT NULL
)
INHERITS (public.calculation_item);

ALTER TABLE ONLY public.calculation_material ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.calculation_material ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.calculation_material ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.calculation_material ALTER COLUMN item_cost SET DEFAULT 0;

ALTER TABLE ONLY public.calculation_material ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE public.calculation_material OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calculation_material TO users;

COMMENT ON TABLE public.calculation_material IS 'Список материалов в калькуляции';

COMMENT ON COLUMN public.calculation_material.item_cost IS 'Сумма';

COMMENT ON COLUMN public.calculation_material.item_id IS 'Ссылка на материал (material)';

COMMENT ON COLUMN public.calculation_material.owner_id IS 'Калькуляция';

COMMENT ON COLUMN public.calculation_material.price IS 'Цена за единицу материала';

COMMENT ON COLUMN public.calculation_material.amount IS 'Количество материала на изделие';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_calculation_material ON public.calculation_material USING btree (owner_id, item_id)
WHERE (NOT deleted);

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_material_ad
	AFTER DELETE ON public.calculation_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_material_aiu
	AFTER INSERT OR UPDATE ON public.calculation_material
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_material_aiu_0
	AFTER INSERT OR UPDATE ON public.calculation_material
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_material_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_material_aiu_1
	AFTER INSERT OR UPDATE ON public.calculation_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_material_changed();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_material_bi
	BEFORE INSERT ON public.calculation_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_material_biu_0
	BEFORE INSERT OR UPDATE ON public.calculation_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_material_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_material_bu
	BEFORE UPDATE ON public.calculation_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_material
	ADD CONSTRAINT fk_calculation_material_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_material
	ADD CONSTRAINT fk_calculation_material_item FOREIGN KEY (item_id) REFERENCES public.material(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_material
	ADD CONSTRAINT fk_calculation_material_owner FOREIGN KEY (owner_id) REFERENCES public.calculation(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_material
	ADD CONSTRAINT fk_calculation_material_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_material
	ADD CONSTRAINT pk_calculation_material_id PRIMARY KEY (id);
