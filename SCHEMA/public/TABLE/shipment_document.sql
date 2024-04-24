CREATE TABLE public.shipment_document (
	contractor_id uuid,
	contract_id uuid
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.shipment_document ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.shipment_document ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.shipment_document ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.shipment_document ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.shipment_document ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.shipment_document OWNER TO postgres;

GRANT SELECT ON TABLE public.shipment_document TO users;

COMMENT ON TABLE public.shipment_document IS 'Документы для работы с контрагентами';

--------------------------------------------------------------------------------

ALTER TABLE public.shipment_document
	ADD CONSTRAINT pk_shipment_document_id PRIMARY KEY (id);
