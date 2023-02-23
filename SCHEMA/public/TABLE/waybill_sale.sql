CREATE TABLE public.waybill_sale (
)
INHERITS (public.waybill);

ALTER TABLE ONLY public.waybill_sale ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.waybill_sale ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.waybill_sale ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.waybill_sale ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.waybill_sale OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.waybill_sale TO users;

COMMENT ON TABLE public.waybill_sale IS 'Продажа (акты / накладные)';

COMMENT ON COLUMN public.waybill_sale.carried_out IS 'Проведен или нет документ';

COMMENT ON COLUMN public.waybill_sale.contract_id IS 'Договор с контрагентом';

COMMENT ON COLUMN public.waybill_sale.contractor_id IS 'Контрагент';

COMMENT ON COLUMN public.waybill_sale.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.waybill_sale.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.waybill_sale.invoice_date IS 'Дата выдачи счёт-фактуры (1С)';

COMMENT ON COLUMN public.waybill_sale.invoice_number IS 'Номер счёт-фактуры (1С)';

COMMENT ON COLUMN public.waybill_sale.owner_id IS 'Заказ на изготовление';

COMMENT ON COLUMN public.waybill_sale.upd IS 'Является ли документ универсальным передаточным документом';

COMMENT ON COLUMN public.waybill_sale.waybill_date IS 'Дата выдачи накладной (1С)';

COMMENT ON COLUMN public.waybill_sale.waybill_number IS 'Номер накладной (1С)';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_waybill_sale_doc_number ON public.waybill_sale USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_sale_ad
	AFTER DELETE ON public.waybill_sale
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER waybill_sale_aiu
	AFTER INSERT OR UPDATE ON public.waybill_sale
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_sale_bu
	BEFORE UPDATE ON public.waybill_sale
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_sale_au_0
	AFTER UPDATE ON public.waybill_sale
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.waybill_sale_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_sale_bi
	BEFORE INSERT ON public.waybill_sale
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_sale_au_1
	AFTER UPDATE ON public.waybill_sale
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER waybill_sale_biu_0
	BEFORE INSERT OR UPDATE ON public.waybill_sale
	FOR EACH ROW
	EXECUTE PROCEDURE public.waybill_changing();

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale
	ADD CONSTRAINT pk_waybill_sale_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale
	ADD CONSTRAINT fk_waybill_sale_contract FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale
	ADD CONSTRAINT fk_waybill_sale_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale
	ADD CONSTRAINT fk_waybill_sale_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale
	ADD CONSTRAINT fk_waybill_sale_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale
	ADD CONSTRAINT fk_waybill_sale_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_sale
	ADD CONSTRAINT fk_waybill_sale_production_order FOREIGN KEY (owner_id) REFERENCES public.production_order(id) ON UPDATE CASCADE ON DELETE SET NULL;
