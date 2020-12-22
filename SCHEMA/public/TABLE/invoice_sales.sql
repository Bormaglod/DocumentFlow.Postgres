CREATE TABLE public.invoice_sales (
)
INHERITS (public.invoice);

ALTER TABLE ONLY public.invoice_sales ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.invoice_sales OWNER TO postgres;

GRANT ALL ON TABLE public.invoice_sales TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.invoice_sales TO users;

COMMENT ON TABLE public.invoice_sales IS 'Реализация (акты / накладные)';

COMMENT ON COLUMN public.invoice_sales.invoice_date IS 'Дата счёт-фактуры';

COMMENT ON COLUMN public.invoice_sales.invoice_number IS 'Номер счёт-фактуры';

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_sales_ad
	AFTER DELETE ON public.invoice_sales
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER invoice_sales_aiu
	AFTER INSERT OR UPDATE ON public.invoice_sales
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_sales_bi
	BEFORE INSERT ON public.invoice_sales
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_sales_bu
	BEFORE UPDATE ON public.invoice_sales
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_sales_au_status
	AFTER UPDATE ON public.invoice_sales
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_invoice_sales();

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_sales_bu_status
	BEFORE UPDATE ON public.invoice_sales
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_invoice_sales();

--------------------------------------------------------------------------------

CREATE TRIGGER invoice_sales_biu
	BEFORE INSERT OR UPDATE ON public.invoice_sales
	FOR EACH ROW
	EXECUTE PROCEDURE public.update_invoice_sales();

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales
	ADD CONSTRAINT fk_invoice_sales_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales
	ADD CONSTRAINT fk_invoice_sales_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales
	ADD CONSTRAINT fk_invoice_sales_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales
	ADD CONSTRAINT fk_invoice_sales_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales
	ADD CONSTRAINT fk_invoice_sales_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales
	ADD CONSTRAINT fk_invoice_sales_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales
	ADD CONSTRAINT fk_invoice_sales_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales
	ADD CONSTRAINT pk_invoice_sales_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.invoice_sales
	ADD CONSTRAINT fk_invoice_sales_contract FOREIGN KEY (contract_id) REFERENCES public.contract(id) ON UPDATE CASCADE;
