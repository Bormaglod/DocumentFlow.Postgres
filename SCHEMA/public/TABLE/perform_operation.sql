CREATE TABLE public.perform_operation (
	order_id uuid,
	goods_id uuid,
	operation_id uuid,
	employee_id uuid,
	amount integer DEFAULT 0,
	using_goods_id uuid,
	replacing_goods_id uuid,
	salary money DEFAULT 0
)
INHERITS (public.document);

ALTER TABLE ONLY public.perform_operation ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.perform_operation OWNER TO postgres;

GRANT ALL ON TABLE public.perform_operation TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.perform_operation TO users;

COMMENT ON TABLE public.perform_operation IS 'Выполненные операции указанными сотрудниками';

COMMENT ON COLUMN public.perform_operation.order_id IS 'Заказ';

COMMENT ON COLUMN public.perform_operation.goods_id IS 'Изделие';

COMMENT ON COLUMN public.perform_operation.operation_id IS 'Операция';

COMMENT ON COLUMN public.perform_operation.employee_id IS 'Исполнитель';

COMMENT ON COLUMN public.perform_operation.amount IS 'Количество выполненных операций';

COMMENT ON COLUMN public.perform_operation.using_goods_id IS 'Использованый материал для этой операции соглано специфиуации';

COMMENT ON COLUMN public.perform_operation.replacing_goods_id IS 'Фактически использованный материал для операции';

COMMENT ON COLUMN public.perform_operation.salary IS 'Заработная плата';

--------------------------------------------------------------------------------

CREATE TRIGGER perform_operation_ad
	AFTER DELETE ON public.perform_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER perform_operation_aiu
	AFTER INSERT OR UPDATE ON public.perform_operation
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER perform_operation_bi
	BEFORE INSERT ON public.perform_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER perform_operation_bu
	BEFORE UPDATE ON public.perform_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER perform_operation_au_status
	AFTER UPDATE ON public.perform_operation
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_perform_operation();

--------------------------------------------------------------------------------

CREATE TRIGGER perform_operation_bu_status
	BEFORE UPDATE ON public.perform_operation
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_perform_operation();

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT pk_perform_operation_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_operation FOREIGN KEY (operation_id) REFERENCES public.operation(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_employee FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_order FOREIGN KEY (order_id) REFERENCES public.production_order(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_using_goods FOREIGN KEY (using_goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.perform_operation
	ADD CONSTRAINT fk_perform_operation_replacing_goods FOREIGN KEY (replacing_goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE;
