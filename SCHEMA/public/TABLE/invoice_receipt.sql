CREATE TABLE public.invoice_receipt (
	receipt_date timestamp with time zone,
	is_tolling boolean DEFAULT false
)
INHERITS (public.invoice);

ALTER TABLE ONLY public.invoice_receipt ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.invoice_receipt OWNER TO postgres;

GRANT ALL ON TABLE public.invoice_receipt TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.invoice_receipt TO users;

COMMENT ON TABLE public.invoice_receipt IS 'Поступление (акты / накладные)';

COMMENT ON COLUMN public.invoice_receipt.invoice_date IS 'Дата счёт-фактуры';

COMMENT ON COLUMN public.invoice_receipt.invoice_number IS 'Номер счёт-фактуры';

COMMENT ON COLUMN public.invoice_receipt.receipt_date IS 'Дата поступления';

COMMENT ON COLUMN public.invoice_receipt.is_tolling IS 'Флаг определяющий тип получаемого товара (false - собственный, true - давальческий)';

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_receipt_ad
	AFTER DELETE ON public.invoice_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_receipt_bi
	BEFORE INSERT ON public.invoice_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_receipt_bu
	BEFORE UPDATE ON public.invoice_receipt
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER invoice_receipt_aiu
	AFTER INSERT OR UPDATE ON public.invoice_receipt
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_receipt_au_status
	AFTER UPDATE ON public.invoice_receipt
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_invoice_receipt();

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_receipt_bu_status
	BEFORE UPDATE ON public.invoice_receipt
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_invoice_receipt();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER invoice_receipt_aiu_1
	AFTER INSERT OR UPDATE ON public.invoice_receipt
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.check_seller_documents();

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_receipt
	ADD CONSTRAINT pk_invoice_receipt_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_receipt
	ADD CONSTRAINT fk_invoice_receipt_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_receipt
	ADD CONSTRAINT fk_invoice_receipt_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_receipt
	ADD CONSTRAINT fk_invoice_receipt_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_receipt
	ADD CONSTRAINT fk_invoice_receipt_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_receipt
	ADD CONSTRAINT fk_invoice_receipt_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_receipt
	ADD CONSTRAINT fk_invoice_receipt_owner FOREIGN KEY (owner_id) REFERENCES public.purchase_request(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_receipt
	ADD CONSTRAINT fk_invoice_receipt_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_receipt
	ADD CONSTRAINT fk_invoice_receipt_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_receipt
	ADD CONSTRAINT fk_invoice_receipt_contract FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON UPDATE CASCADE;
