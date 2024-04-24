CREATE TABLE public.operations_performed (
	employee_id uuid NOT NULL,
	operation_id uuid NOT NULL,
	replacing_material_id uuid,
	quantity integer DEFAULT 0 NOT NULL,
	salary numeric(15,2) DEFAULT 0 NOT NULL,
	double_rate boolean DEFAULT false,
	skip_material boolean DEFAULT false
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.operations_performed ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.operations_performed ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.operations_performed ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.operations_performed ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.operations_performed ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.operations_performed OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operations_performed TO users;

COMMENT ON TABLE public.operations_performed IS 'Выполненные операции указанными сотрудниками';

COMMENT ON COLUMN public.operations_performed.owner_id IS 'Производственная партия';

COMMENT ON COLUMN public.operations_performed.employee_id IS 'Исполнитель';

COMMENT ON COLUMN public.operations_performed.operation_id IS 'Операция';

COMMENT ON COLUMN public.operations_performed.replacing_material_id IS 'Фактически использованный материал для операции';

COMMENT ON COLUMN public.operations_performed.quantity IS 'Количество выполненных операций';

COMMENT ON COLUMN public.operations_performed.salary IS 'Заработная плата';

COMMENT ON COLUMN public.operations_performed.double_rate IS 'Оплата по двойному тарифу';

COMMENT ON COLUMN public.operations_performed.skip_material IS 'Если флаг установлен в TRUE, то использованный материал для операции не будет учитываться';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_operations_performed_doc_number ON public.operations_performed USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER operations_performed_ad
	AFTER DELETE ON public.operations_performed
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER operations_performed_aiu_0
	AFTER INSERT OR UPDATE ON public.operations_performed
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER operations_performed_aiu_1
	AFTER INSERT OR UPDATE ON public.operations_performed
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.operations_performed_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER operations_performed_au_0
	AFTER UPDATE ON public.operations_performed
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.operations_performed_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER operations_performed_au_1
	AFTER UPDATE ON public.operations_performed
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER operations_performed_bi
	BEFORE INSERT ON public.operations_performed
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER operations_performed_biu_0
	BEFORE INSERT OR UPDATE ON public.operations_performed
	FOR EACH ROW
	EXECUTE PROCEDURE public.operations_performed_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER operations_performed_bu
	BEFORE UPDATE ON public.operations_performed
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.operations_performed
	ADD CONSTRAINT fk_operations_performed_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operations_performed
	ADD CONSTRAINT fk_operations_performed_employee FOREIGN KEY (employee_id) REFERENCES public.our_employee(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operations_performed
	ADD CONSTRAINT fk_operations_performed_lot FOREIGN KEY (owner_id) REFERENCES public.production_lot(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operations_performed
	ADD CONSTRAINT fk_operations_performed_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operations_performed
	ADD CONSTRAINT fk_operations_performed_replacing_material FOREIGN KEY (replacing_material_id) REFERENCES public.material(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operations_performed
	ADD CONSTRAINT fk_operations_performed_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operations_performed
	ADD CONSTRAINT pk_operations_performed_id PRIMARY KEY (id);
