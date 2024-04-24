CREATE TABLE public.production_lot (
	calculation_id uuid NOT NULL,
	quantity numeric(12,3) NOT NULL,
	state public.lot_state DEFAULT 'created'::public.lot_state NOT NULL,
	sold boolean DEFAULT false
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.production_lot ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.production_lot ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.production_lot ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.production_lot ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.production_lot ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.production_lot OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.production_lot TO users;

COMMENT ON TABLE public.production_lot IS 'Поизводственная партия';

COMMENT ON COLUMN public.production_lot.owner_id IS 'Заказ на изготовление';

COMMENT ON COLUMN public.production_lot.calculation_id IS 'Калькуляция используемая для изготовления';

COMMENT ON COLUMN public.production_lot.quantity IS 'Количество изделий в партии';

COMMENT ON COLUMN public.production_lot.state IS 'Состояние партии';

COMMENT ON COLUMN public.production_lot.sold IS 'Флаг определяющий, что партия реализована (если партия реализована частично - то NULL)';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_production_lot_doc_number ON public.production_lot USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER production_lot_ad_0
	AFTER DELETE ON public.production_lot
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER production_lot_aiu
	AFTER INSERT OR UPDATE ON public.production_lot
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER production_lot_au_0
	AFTER UPDATE ON public.production_lot
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.production_lot_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER production_lot_au_1
	AFTER UPDATE ON public.production_lot
	FOR EACH ROW
	WHEN (((old.deleted <> new.deleted) AND new.deleted))
	EXECUTE PROCEDURE public.production_lot_mark();

--------------------------------------------------------------------------------

CREATE TRIGGER production_lot_au_2
	AFTER UPDATE ON public.production_lot
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER production_lot_bi
	BEFORE INSERT ON public.production_lot
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER production_lot_bu_0
	BEFORE UPDATE ON public.production_lot
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER production_lot_bu_1
	BEFORE UPDATE ON public.production_lot
	FOR EACH ROW
	EXECUTE PROCEDURE public.production_lot_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.production_lot
	ADD CONSTRAINT fk_production_lot_calculation FOREIGN KEY (calculation_id) REFERENCES public.calculation(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_lot
	ADD CONSTRAINT fk_production_lot_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_lot
	ADD CONSTRAINT fk_production_lot_order FOREIGN KEY (owner_id) REFERENCES public.production_order(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_lot
	ADD CONSTRAINT fk_production_lot_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_lot
	ADD CONSTRAINT fk_production_lot_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.production_lot
	ADD CONSTRAINT pk_production_lot_id PRIMARY KEY (id);
