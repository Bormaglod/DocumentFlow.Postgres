CREATE TABLE public.balance_material (
	id uuid DEFAULT public.uuid_generate_v4(),
	owner_id uuid,
	user_created_id uuid,
	date_created timestamp with time zone,
	user_updated_id uuid,
	date_updated timestamp with time zone,
	deleted boolean DEFAULT false,
	organization_id uuid,
	document_date timestamp(0) with time zone,
	document_number integer,
	reference_id uuid,
	operation_summa numeric(15,2) DEFAULT 0,
	amount numeric(12,3) DEFAULT 0,
	document_type_id uuid
)
INHERITS (public.balance_product);

ALTER TABLE public.balance_material OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.balance_material TO users;
GRANT SELECT ON TABLE public.balance_material TO managers;

COMMENT ON COLUMN public.balance_material.owner_id IS 'Ссылка на документ который сформировал эту запись';

COMMENT ON COLUMN public.balance_material.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.balance_material.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.balance_material.reference_id IS 'Ссылка на материал по которому считаются остатки';

COMMENT ON COLUMN public.balance_material.operation_summa IS 'Сумма операции';

COMMENT ON COLUMN public.balance_material.amount IS 'Количество материала';

COMMENT ON COLUMN public.balance_material.document_type_id IS 'Ссылка на тип документа который сформировал эту запись';

--------------------------------------------------------------------------------

CREATE INDEX idx_balance_material_owner ON public.balance_material USING btree (owner_id);

--------------------------------------------------------------------------------

CREATE TRIGGER balance_material_ad
	AFTER DELETE ON public.balance_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_material_aiu
	AFTER INSERT OR UPDATE ON public.balance_material
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_material_bi
	BEFORE INSERT ON public.balance_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_material_bu
	BEFORE UPDATE ON public.balance_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_material_aiu_0
	AFTER INSERT OR UPDATE ON public.balance_material
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.balance_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_material_ad_0
	AFTER DELETE ON public.balance_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.balance_material_deleted();

--------------------------------------------------------------------------------

ALTER TABLE public.balance_material
	ADD CONSTRAINT pk_balance_material_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.balance_material
	ADD CONSTRAINT fk_balance_material_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_material
	ADD CONSTRAINT fk_balance_material_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_material
	ADD CONSTRAINT fk_balance_material_document_type FOREIGN KEY (document_type_id) REFERENCES public.document_type(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_material
	ADD CONSTRAINT fk_balance_material_reference FOREIGN KEY (reference_id) REFERENCES public.material(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_material
	ADD CONSTRAINT fk_balance_material_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;
