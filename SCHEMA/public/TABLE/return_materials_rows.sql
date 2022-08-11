CREATE TABLE public.return_materials_rows (
	id bigint DEFAULT nextval('public.return_materials_rows_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	material_id uuid NOT NULL,
	quantity numeric(12,3) NOT NULL
);

ALTER TABLE public.return_materials_rows OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.return_materials_rows TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.return_materials_rows
	ADD CONSTRAINT fk_return_materials_rows_owner FOREIGN KEY (owner_id) REFERENCES public.return_materials(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.return_materials_rows
	ADD CONSTRAINT fk_return_materials_rows_material FOREIGN KEY (material_id) REFERENCES public.material(id) ON UPDATE CASCADE;
