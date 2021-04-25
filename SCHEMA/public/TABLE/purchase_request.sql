CREATE TABLE public.purchase_request (
	contractor_id uuid,
	contract_id uuid
)
INHERITS (public.document);

ALTER TABLE ONLY public.purchase_request ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.purchase_request OWNER TO postgres;

GRANT ALL ON TABLE public.purchase_request TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.purchase_request TO users;

COMMENT ON TABLE public.purchase_request IS 'Заявка за закупку комплектующих/материалов';

COMMENT ON COLUMN public.purchase_request.doc_date IS 'Дата заявки';

COMMENT ON COLUMN public.purchase_request.doc_number IS 'Номер заявки';

COMMENT ON COLUMN public.purchase_request.organization_id IS 'Наша организация';

COMMENT ON COLUMN public.purchase_request.contractor_id IS 'Контрагент';

COMMENT ON COLUMN public.purchase_request.contract_id IS 'Договор';

--------------------------------------------------------------------------------

CREATE TRIGGER purchase_request_ad
	AFTER DELETE ON public.purchase_request
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER purchase_request_aiu
	AFTER INSERT OR UPDATE ON public.purchase_request
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER purchase_request_bi
	BEFORE INSERT ON public.purchase_request
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER purchase_request_bu
	BEFORE UPDATE ON public.purchase_request
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER purchase_request_au_status
	AFTER UPDATE ON public.purchase_request
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_purchase_request();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER purchase_request_aiu_1
	AFTER INSERT OR UPDATE ON public.purchase_request
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.check_seller_documents();

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT pk_purchase_request_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_contract FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON UPDATE CASCADE;
