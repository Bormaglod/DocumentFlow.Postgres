CREATE TABLE public.purchase_request (
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
	note text,
	pstate public.purchase_state DEFAULT 'not active'::public.purchase_state NOT NULL
)
INHERITS (public.shipment_document);

ALTER TABLE ONLY public.purchase_request ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.purchase_request OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.purchase_request TO users;

COMMENT ON TABLE public.purchase_request IS 'Заявка за закупку комплектующих/материалов';

COMMENT ON COLUMN public.purchase_request.organization_id IS 'Наша организация';

COMMENT ON COLUMN public.purchase_request.document_date IS 'Дата заявки';

COMMENT ON COLUMN public.purchase_request.document_number IS 'Номер заявки';

COMMENT ON COLUMN public.purchase_request.contractor_id IS 'Контрагент';

COMMENT ON COLUMN public.purchase_request.contract_id IS 'Договор';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_purchase_request_doc_number ON public.purchase_request USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER purchase_request_ad
	AFTER DELETE ON public.purchase_request
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER purchase_request_aiu_0
	AFTER INSERT OR UPDATE ON public.purchase_request
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER purchase_request_aiu_1
	AFTER INSERT OR UPDATE ON public.purchase_request
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.purchase_request_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER purchase_request_au_0
	AFTER UPDATE ON public.purchase_request
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.purchase_request_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER purchase_request_au_1
	AFTER UPDATE ON public.purchase_request
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER purchase_request_bi
	BEFORE INSERT ON public.purchase_request
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER purchase_request_biu_0
	BEFORE INSERT OR UPDATE ON public.purchase_request
	FOR EACH ROW
	EXECUTE PROCEDURE public.purchase_request_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER purchase_request_bu
	BEFORE UPDATE ON public.purchase_request
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_contract FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_state FOREIGN KEY (state_id) REFERENCES public.state(id) ON UPDATE CASCADE ON DELETE RESTRICT;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT fk_purchase_request_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request
	ADD CONSTRAINT pk_purchase_request_id PRIMARY KEY (id);
