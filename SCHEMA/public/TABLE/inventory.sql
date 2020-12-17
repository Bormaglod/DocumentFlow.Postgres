CREATE TABLE public.inventory (
	employee_id uuid
)
INHERITS (public.document);

ALTER TABLE ONLY public.inventory ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.inventory OWNER TO postgres;

GRANT ALL ON TABLE public.inventory TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inventory TO users;

COMMENT ON TABLE public.inventory IS 'Инвентаризация';

COMMENT ON COLUMN public.inventory.employee_id IS 'Ответственный сотрудник';

--------------------------------------------------------------------------------

CREATE TRIGGER inventory_ad
	AFTER DELETE ON public.inventory
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER inventory_aiu
	AFTER INSERT OR UPDATE ON public.inventory
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER inventory_bi
	BEFORE INSERT ON public.inventory
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER inventory_bu
	BEFORE UPDATE ON public.inventory
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER inventory_au_status
	AFTER UPDATE ON public.inventory
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_inventory();

--------------------------------------------------------------------------------

CREATE TRIGGER inventory_bu_status
	BEFORE UPDATE ON public.inventory
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_inventory();

--------------------------------------------------------------------------------

ALTER TABLE public.inventory
	ADD CONSTRAINT fk_inventory_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.inventory
	ADD CONSTRAINT fk_inventory_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.inventory
	ADD CONSTRAINT fk_inventory_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.inventory
	ADD CONSTRAINT fk_inventory_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.inventory
	ADD CONSTRAINT fk_inventory_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.inventory
	ADD CONSTRAINT fk_inventory_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.inventory
	ADD CONSTRAINT fk_inventory_employee FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.inventory
	ADD CONSTRAINT pk_inventory_id PRIMARY KEY (id);
