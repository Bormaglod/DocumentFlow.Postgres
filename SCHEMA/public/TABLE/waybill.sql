CREATE TABLE public.waybill (
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
	carried_out boolean DEFAULT false,
	re_carried_out boolean DEFAULT false,
	contractor_id uuid,
	contract_id uuid,
	waybill_number character varying(20),
	waybill_date date,
	invoice_number character varying(20),
	invoice_date date,
	upd boolean
)
INHERITS (public.shipment_document);

ALTER TABLE ONLY public.waybill ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.waybill OWNER TO postgres;

GRANT SELECT ON TABLE public.waybill TO users;

COMMENT ON COLUMN public.waybill.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.waybill.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.waybill.carried_out IS 'Проведен или нет документ';

COMMENT ON COLUMN public.waybill.contractor_id IS 'Контрагент';

COMMENT ON COLUMN public.waybill.contract_id IS 'Договор с контрагентом';

COMMENT ON COLUMN public.waybill.waybill_number IS 'Номер накладной (1С)';

COMMENT ON COLUMN public.waybill.waybill_date IS 'Дата выдачи накладной (1С)';

COMMENT ON COLUMN public.waybill.invoice_number IS 'Номер счёт-фактуры (1С)';

COMMENT ON COLUMN public.waybill.invoice_date IS 'Дата выдачи счёт-фактуры (1С)';

COMMENT ON COLUMN public.waybill.upd IS 'Является ли документ универсальным передаточным документом';

--------------------------------------------------------------------------------

ALTER TABLE public.waybill
	ADD CONSTRAINT pk_waybill_id PRIMARY KEY (id);
