CREATE TABLE public.material (
	min_order numeric(15,3),
	ext_article character varying(100),
	wire_id uuid,
	material_kind public.material_kind DEFAULT 'undefined'::public.material_kind NOT NULL
)
INHERITS (public.product);

ALTER TABLE ONLY public.material ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.material ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.material ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.material OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.material TO users;
GRANT SELECT ON TABLE public.material TO managers;

COMMENT ON COLUMN public.material.code IS 'Артикул';

COMMENT ON COLUMN public.material.doc_name IS 'Наименование используемое в документах';

COMMENT ON COLUMN public.material.measurement_id IS 'Единица измерения';

COMMENT ON COLUMN public.material.owner_id IS 'Кросс-артикул';

COMMENT ON COLUMN public.material.price IS 'Цена покупки';

COMMENT ON COLUMN public.material.vat IS 'Ставка НДС';

COMMENT ON COLUMN public.material.weight IS 'Вес';

COMMENT ON COLUMN public.material.min_order IS 'Минимальный заказ';

COMMENT ON COLUMN public.material.ext_article IS 'Доп. артикул';

COMMENT ON COLUMN public.material.wire_id IS 'Тип провода (для записей в группе "Провода")';

COMMENT ON COLUMN public.material.material_kind IS 'Тип материала';

--------------------------------------------------------------------------------

CREATE TRIGGER material_ad
	AFTER DELETE ON public.material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER material_aiu
	AFTER INSERT OR UPDATE ON public.material
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER material_bi
	BEFORE INSERT ON public.material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER material_biu_0
	BEFORE INSERT OR UPDATE ON public.material
	FOR EACH ROW
	EXECUTE PROCEDURE public.material_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER material_bu
	BEFORE UPDATE ON public.material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.material
	ADD CONSTRAINT pk_material_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.material
	ADD CONSTRAINT unq_material_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.material
	ADD CONSTRAINT fk_material_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.material
	ADD CONSTRAINT fk_material_measurement FOREIGN KEY (measurement_id) REFERENCES public.measurement(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.material
	ADD CONSTRAINT fk_material_parent FOREIGN KEY (parent_id) REFERENCES public.material(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.material
	ADD CONSTRAINT fk_material_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.material
	ADD CONSTRAINT fk_material_cross FOREIGN KEY (owner_id) REFERENCES public.material(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.material
	ADD CONSTRAINT fk_material_wire FOREIGN KEY (wire_id) REFERENCES public.wire(id) ON UPDATE CASCADE ON DELETE SET NULL;
