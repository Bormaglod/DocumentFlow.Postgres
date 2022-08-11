CREATE TABLE public.return_materials (
	contractor_id uuid,
	contract_id uuid
)
INHERITS (public.shipment_document);

ALTER TABLE ONLY public.return_materials ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.return_materials ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.return_materials ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.return_materials ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.return_materials OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.return_materials TO users;

COMMENT ON TABLE public.return_materials IS 'Возврат материалов заказчику';

COMMENT ON COLUMN public.return_materials.carried_out IS 'Проведен или нет документ';

COMMENT ON COLUMN public.return_materials.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.return_materials.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.return_materials.owner_id IS 'Заказ на изготовление';

COMMENT ON COLUMN public.return_materials.contractor_id IS 'Контрагент';

COMMENT ON COLUMN public.return_materials.contract_id IS 'Договор с контрагентом';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_return_materials_doc_number ON public.return_materials USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER return_materials_ad
	AFTER DELETE ON public.return_materials
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER return_materials_aiu
	AFTER INSERT OR UPDATE ON public.return_materials
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER return_materials_au_0
	AFTER UPDATE ON public.return_materials
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.return_materials_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER return_materials_bi
	BEFORE INSERT ON public.return_materials
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER return_materials_bu
	BEFORE UPDATE ON public.return_materials
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER return_materials_au_1
	AFTER UPDATE ON public.return_materials
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.return_materials
	ADD CONSTRAINT pk_return_materials_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.return_materials
	ADD CONSTRAINT fk_return_materials_contract FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.return_materials
	ADD CONSTRAINT fk_return_materials_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.return_materials
	ADD CONSTRAINT fk_return_materials_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.return_materials
	ADD CONSTRAINT fk_return_materials_order FOREIGN KEY (owner_id) REFERENCES public.production_order(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.return_materials
	ADD CONSTRAINT fk_return_materials_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.return_materials
	ADD CONSTRAINT fk_return_materials_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
