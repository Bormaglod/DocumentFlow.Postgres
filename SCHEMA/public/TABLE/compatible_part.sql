CREATE TABLE public.compatible_part (
	id bigint DEFAULT nextval('public.compatible_part_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	compatible_id uuid NOT NULL
);

ALTER TABLE public.compatible_part OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.compatible_part TO users;

COMMENT ON COLUMN public.compatible_part.owner_id IS 'Материал';

COMMENT ON COLUMN public.compatible_part.compatible_id IS 'Совместимая деталь';

--------------------------------------------------------------------------------

CREATE TRIGGER compatible_part_aiud
	AFTER INSERT OR UPDATE OR DELETE ON public.compatible_part
	FOR EACH ROW
	EXECUTE PROCEDURE public.compatible_part_changed();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER compatible_part_aiu
	AFTER INSERT OR UPDATE ON public.compatible_part
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.compatible_part_checking();

--------------------------------------------------------------------------------

ALTER TABLE public.compatible_part
	ADD CONSTRAINT fk_compatible_part_material FOREIGN KEY (owner_id) REFERENCES public.material(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.compatible_part
	ADD CONSTRAINT fk_compatible_part FOREIGN KEY (compatible_id) REFERENCES public.material(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.compatible_part
	ADD CONSTRAINT pk_compatible_part_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.compatible_part
	ADD CONSTRAINT unq_compatible_part UNIQUE (owner_id, compatible_id);

--------------------------------------------------------------------------------

ALTER TABLE public.compatible_part
	ADD CONSTRAINT chk_compatible_part CHECK ((owner_id <> compatible_id));
