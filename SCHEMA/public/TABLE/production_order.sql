CREATE TABLE public.production_order (
	contractor_id uuid
)
INHERITS (public.document);

ALTER TABLE ONLY public.production_order ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.production_order OWNER TO postgres;

GRANT ALL ON TABLE public.production_order TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.production_order TO users;

COMMENT ON TABLE public.production_order IS 'Заказ на изготовление';

--------------------------------------------------------------------------------

CREATE TRIGGER production_order_ad
	AFTER DELETE ON public.production_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER production_order_aiu
	AFTER INSERT OR UPDATE ON public.production_order
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER production_order_bi
	BEFORE INSERT ON public.production_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER production_order_bu
	BEFORE UPDATE ON public.production_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER production_order_au_status
	AFTER UPDATE ON public.production_order
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_production_order();

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT pk_production_order_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;
