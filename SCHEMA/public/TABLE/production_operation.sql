CREATE TABLE public.production_operation (
	goods_id uuid,
	operation_id uuid,
	amount integer DEFAULT 0,
	completed integer DEFAULT 0,
	manufactured integer DEFAULT 0
)
INHERITS (public.document);

ALTER TABLE ONLY public.production_operation ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.production_operation OWNER TO postgres;

GRANT ALL ON TABLE public.production_operation TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.production_operation TO users;

COMMENT ON TABLE public.production_operation IS 'Производственные операции';

COMMENT ON COLUMN public.production_operation.owner_id IS 'Идентификатор заказа на изготовление';

COMMENT ON COLUMN public.production_operation.goods_id IS 'Идентификатор изделия';

COMMENT ON COLUMN public.production_operation.operation_id IS 'Идентификатор операции';

COMMENT ON COLUMN public.production_operation.amount IS 'Количество операций необходимых для выполнения заказа';

COMMENT ON COLUMN public.production_operation.completed IS 'Количество выполненных операций';

--------------------------------------------------------------------------------

CREATE TRIGGER production_operation_ad
	AFTER DELETE ON public.production_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER production_operation_aiu
	AFTER INSERT OR UPDATE ON public.production_operation
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER production_operation_bi
	BEFORE INSERT ON public.production_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER production_operation_bu
	BEFORE UPDATE ON public.production_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT fk_production_operation_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT fk_production_operation_operation FOREIGN KEY (operation_id) REFERENCES public.operation(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT fk_production_operation_owner FOREIGN KEY (owner_id) REFERENCES public.production_order(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT pk_production_operation_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT fk_production_operation_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT fk_production_operation_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT fk_production_operation_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT fk_production_operation_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT fk_production_operation_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT fk_production_operation_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT chk_production_operation_amount CHECK ((completed <= amount));

COMMENT ON CONSTRAINT chk_production_operation_amount ON public.production_operation IS 'Количество выполненных операций не должно превышать общее количество операций';

--------------------------------------------------------------------------------

ALTER TABLE public.production_operation
	ADD CONSTRAINT chk_production_operation_completed CHECK ((manufactured <= completed));

COMMENT ON CONSTRAINT chk_production_operation_completed ON public.production_operation IS 'Количество операций, которые были учтены в изготовленных изделиях не может превышать общее количество выполненных операций';
