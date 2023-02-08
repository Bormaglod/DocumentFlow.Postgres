CREATE TABLE public.equipment (
	is_tools boolean DEFAULT false NOT NULL,
	serial_number character varying(20),
	commissioning date,
	starting_hits integer
)
INHERITS (public.directory);

ALTER TABLE ONLY public.equipment ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.equipment ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.equipment ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.equipment OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.equipment TO users;

COMMENT ON TABLE public.equipment IS 'Оборудовани и инструмент';

COMMENT ON COLUMN public.equipment.is_tools IS 'Оборудование является инструментом';

COMMENT ON COLUMN public.equipment.serial_number IS 'Серийный номер';

COMMENT ON COLUMN public.equipment.commissioning IS 'Дата ввода в эксплуатацию';

COMMENT ON COLUMN public.equipment.starting_hits IS '(только для аппликаторов) начальное количество опрессовок';

--------------------------------------------------------------------------------

CREATE TRIGGER equipment_ad
	AFTER DELETE ON public.equipment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER equipment_aiu
	AFTER INSERT OR UPDATE ON public.equipment
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER equipment_bi
	BEFORE INSERT ON public.equipment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER equipment_bu
	BEFORE UPDATE ON public.equipment
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.equipment
	ADD CONSTRAINT pk_equipment_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.equipment
	ADD CONSTRAINT fk_equipment_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.equipment
	ADD CONSTRAINT fk_equipment_parent FOREIGN KEY (parent_id) REFERENCES public.equipment(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.equipment
	ADD CONSTRAINT fk_equipment_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
