CREATE TABLE public.payment_order (
	contractor_id uuid,
	date_debited date,
	amount_debited money,
	direction public.document_direction,
	purchase_id uuid
)
INHERITS (public.document);

ALTER TABLE ONLY public.payment_order ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.payment_order OWNER TO postgres;

GRANT ALL ON TABLE public.payment_order TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.payment_order TO users;

COMMENT ON TABLE public.payment_order IS 'Платежный ордер';

COMMENT ON COLUMN public.payment_order.doc_date IS 'Дата платежного поручения';

COMMENT ON COLUMN public.payment_order.doc_number IS 'Номер платежного поручения';

COMMENT ON COLUMN public.payment_order.contractor_id IS 'Контрагент (получатель, если direction = -1 или плательщик, если direction = 1)';

COMMENT ON COLUMN public.payment_order.date_debited IS 'Дата списания денежных средств';

COMMENT ON COLUMN public.payment_order.amount_debited IS 'Сумма списания';

COMMENT ON COLUMN public.payment_order.direction IS 'Направление списания';

COMMENT ON COLUMN public.payment_order.purchase_id IS 'Заявка на расход';

--------------------------------------------------------------------------------

CREATE TRIGGER payment_order_bu_status
	BEFORE UPDATE ON public.payment_order
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_payment_order();

--------------------------------------------------------------------------------

CREATE TRIGGER payment_order_ad
	AFTER DELETE ON public.payment_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER payment_order_aiu
	AFTER INSERT OR UPDATE ON public.payment_order
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER payment_order_bi
	BEFORE INSERT ON public.payment_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER payment_order_bu
	BEFORE UPDATE ON public.payment_order
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER payment_order_au_status
	AFTER UPDATE ON public.payment_order
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_payment_order();

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT pk_payment_order_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.payment_order
	ADD CONSTRAINT fk_payment_order_purchase FOREIGN KEY (purchase_id) REFERENCES public.purchase_request(id) ON UPDATE CASCADE;
