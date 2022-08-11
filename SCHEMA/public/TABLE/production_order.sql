CREATE TABLE public.production_order (
	closed boolean DEFAULT false NOT NULL
)
INHERITS (public.shipment_document);

ALTER TABLE ONLY public.production_order ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.production_order ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.production_order ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.production_order ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.production_order OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.production_order TO users;

COMMENT ON TABLE public.production_order IS 'Заказ на изготовление';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_production_order_doc_number ON public.production_order USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER production_order_bu
	BEFORE UPDATE ON public.production_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER production_order_aiu
	AFTER INSERT OR UPDATE ON public.production_order
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER production_order_bi
	BEFORE INSERT ON public.production_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER production_order_ad_0
	AFTER DELETE ON public.production_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE TRIGGER production_order_au_0
	AFTER UPDATE ON public.production_order
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.production_order_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER production_order_au_1
	AFTER UPDATE ON public.production_order
	FOR EACH ROW
	WHEN (((old.deleted <> new.deleted) AND new.deleted))
	EXECUTE PROCEDURE public.production_order_mark();

--------------------------------------------------------------------------------

CREATE TRIGGER production_order_au_2
	AFTER UPDATE ON public.production_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT pk_production_order_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_contract FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_order
	ADD CONSTRAINT fk_production_order_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
