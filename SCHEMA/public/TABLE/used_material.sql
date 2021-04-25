CREATE TABLE public.used_material (
	id bigint DEFAULT nextval('public.used_material_id_seq'::regclass) NOT NULL,
	calc_item_operation_id uuid,
	goods_id uuid,
	count_by_goods numeric(12,3),
	count_by_operation numeric(12,3)
);

ALTER TABLE public.used_material OWNER TO postgres;

GRANT ALL ON TABLE public.used_material TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.used_material TO users;

COMMENT ON COLUMN public.used_material.count_by_goods IS 'Количество материала на изделие';

COMMENT ON COLUMN public.used_material.count_by_operation IS 'Количество материала на операцию';

--------------------------------------------------------------------------------

ALTER TABLE public.used_material
	ADD CONSTRAINT pk_used_material_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.used_material
	ADD CONSTRAINT fk_used_material_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.used_material
	ADD CONSTRAINT fk_used_material_operation FOREIGN KEY (calc_item_operation_id) REFERENCES public.calc_item_operation(id) ON UPDATE CASCADE ON DELETE CASCADE;
