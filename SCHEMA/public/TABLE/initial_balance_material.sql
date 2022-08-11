CREATE TABLE public.initial_balance_material (
	reference_id uuid,
	operation_summa numeric(15,2) DEFAULT 0,
	amount numeric(12,3) DEFAULT 0
)
INHERITS (public.initial_balance);

ALTER TABLE ONLY public.initial_balance_material ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance_material ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance_material ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.initial_balance_material ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.initial_balance_material OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.initial_balance_material TO users;

COMMENT ON COLUMN public.initial_balance_material.document_date IS 'Дата на которую определен остаток';

COMMENT ON COLUMN public.initial_balance_material.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.initial_balance_material.reference_id IS 'Ссылка на справочник по которому определяется начальный остаток';

COMMENT ON COLUMN public.initial_balance_material.operation_summa IS 'Сумма операции';

COMMENT ON COLUMN public.initial_balance_material.amount IS 'Количество';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_initial_balance_material_reference_id ON public.initial_balance_material USING btree (reference_id);

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_initial_balance_material_doc_number ON public.initial_balance_material USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_material_ad
	AFTER DELETE ON public.initial_balance_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER initial_balance_material_aiu
	AFTER INSERT OR UPDATE ON public.initial_balance_material
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_material_au_1
	AFTER UPDATE ON public.initial_balance_material
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.initial_balance_product_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_material_bi
	BEFORE INSERT ON public.initial_balance_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_material_bu
	BEFORE UPDATE ON public.initial_balance_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER initial_balance_material_au_0
	AFTER UPDATE ON public.initial_balance_material
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.initial_balance_product_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_material_au_2
	AFTER UPDATE ON public.initial_balance_material
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_material
	ADD CONSTRAINT pk_initial_balance_material_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_material
	ADD CONSTRAINT fk_initial_balance_material_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_material
	ADD CONSTRAINT fk_initial_balance_material_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_material
	ADD CONSTRAINT fk_initial_balance_material_reference FOREIGN KEY (reference_id) REFERENCES public.material(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_material
	ADD CONSTRAINT fk_initial_balance_material_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
