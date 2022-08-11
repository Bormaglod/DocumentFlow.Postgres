CREATE TABLE public.waybill_processing (
)
INHERITS (public.waybill);

ALTER TABLE ONLY public.waybill_processing ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.waybill_processing ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.waybill_processing ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.waybill_processing ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.waybill_processing OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.waybill_processing TO users;

COMMENT ON TABLE public.waybill_processing IS 'Поступление в переработку';

COMMENT ON COLUMN public.waybill_processing.carried_out IS 'Проведен или нет документ';

COMMENT ON COLUMN public.waybill_processing.contract_id IS 'Договор с контрагентом';

COMMENT ON COLUMN public.waybill_processing.contractor_id IS 'Контрагент';

COMMENT ON COLUMN public.waybill_processing.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.waybill_processing.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.waybill_processing.invoice_date IS 'Дата выдачи счёт-фактуры (1С)';

COMMENT ON COLUMN public.waybill_processing.invoice_number IS 'Номер счёт-фактуры (1С)';

COMMENT ON COLUMN public.waybill_processing.owner_id IS 'Заказ на изготовление';

COMMENT ON COLUMN public.waybill_processing.upd IS 'Является ли документ универсальным передаточным документом';

COMMENT ON COLUMN public.waybill_processing.waybill_date IS 'Дата выдачи накладной (1С)';

COMMENT ON COLUMN public.waybill_processing.waybill_number IS 'Номер накладной (1С)';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_waybill_processing_doc_number ON public.waybill_processing USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_processing_ad
	AFTER DELETE ON public.waybill_processing
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER waybill_processing_aiu
	AFTER INSERT OR UPDATE ON public.waybill_processing
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_processing_bi
	BEFORE INSERT ON public.waybill_processing
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_processing_bu
	BEFORE UPDATE ON public.waybill_processing
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_processing_biu_0
	BEFORE INSERT OR UPDATE ON public.waybill_processing
	FOR EACH ROW
	EXECUTE PROCEDURE public.waybill_receipt_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_processing_au_0
	AFTER UPDATE ON public.waybill_processing
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.waybill_receipt_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_processing_au_1
	AFTER UPDATE ON public.waybill_processing
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing
	ADD CONSTRAINT pk_waybill_processing_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing
	ADD CONSTRAINT fk_waybill_processing_contract FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing
	ADD CONSTRAINT fk_waybill_processing_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing
	ADD CONSTRAINT fk_waybill_processing_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing
	ADD CONSTRAINT fk_waybill_processing_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing
	ADD CONSTRAINT fk_waybill_processing_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing
	ADD CONSTRAINT fk_waybill_processing_order FOREIGN KEY (owner_id) REFERENCES public.production_order(id) ON UPDATE CASCADE;
