CREATE TABLE public.waybill_receipt (
)
INHERITS (public.waybill);

ALTER TABLE ONLY public.waybill_receipt ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.waybill_receipt ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.waybill_receipt ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.waybill_receipt ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.waybill_receipt OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.waybill_receipt TO users;

COMMENT ON TABLE public.waybill_receipt IS 'Поступление (акты / накладные)';

COMMENT ON COLUMN public.waybill_receipt.carried_out IS 'Проведен или нет документ';

COMMENT ON COLUMN public.waybill_receipt.contract_id IS 'Договор с контрагентом';

COMMENT ON COLUMN public.waybill_receipt.contractor_id IS 'Контрагент';

COMMENT ON COLUMN public.waybill_receipt.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.waybill_receipt.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.waybill_receipt.invoice_date IS 'Дата выдачи счёт-фактуры (1С)';

COMMENT ON COLUMN public.waybill_receipt.invoice_number IS 'Номер счёт-фактуры (1С)';

COMMENT ON COLUMN public.waybill_receipt.owner_id IS 'Заявка на закупку';

COMMENT ON COLUMN public.waybill_receipt.upd IS 'Является ли документ универсальным передаточным документом';

COMMENT ON COLUMN public.waybill_receipt.waybill_date IS 'Дата выдачи накладной (1С)';

COMMENT ON COLUMN public.waybill_receipt.waybill_number IS 'Номер накладной (1С)';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_waybill_receipt_doc_number ON public.waybill_receipt USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_receipt_ad
	AFTER DELETE ON public.waybill_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER waybill_receipt_aiu
	AFTER INSERT OR UPDATE ON public.waybill_receipt
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_receipt_bi
	BEFORE INSERT ON public.waybill_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_receipt_bu
	BEFORE UPDATE ON public.waybill_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_receipt_au_0
	AFTER UPDATE ON public.waybill_receipt
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.waybill_receipt_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_receipt_biu_0
	BEFORE INSERT OR UPDATE ON public.waybill_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.waybill_receipt_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_receipt_au_1
	AFTER UPDATE ON public.waybill_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_receipt
	ADD CONSTRAINT pk_waybill_receipt_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_receipt
	ADD CONSTRAINT fk_waybill_receipt_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_receipt
	ADD CONSTRAINT fk_waybill_receipt_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_receipt
	ADD CONSTRAINT fk_waybill_receipt_contract FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_receipt
	ADD CONSTRAINT fk_waybill_receipt_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_receipt
	ADD CONSTRAINT fk_waybill_receipt_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;
