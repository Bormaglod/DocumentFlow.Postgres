CREATE TABLE public.lot_sale (
	id bigint DEFAULT nextval('public.lot_sale_id_seq'::regclass) NOT NULL,
	waybill_sale_id uuid NOT NULL,
	lot_id uuid NOT NULL,
	quantity integer NOT NULL
);

ALTER TABLE public.lot_sale OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.lot_sale TO users;

COMMENT ON COLUMN public.lot_sale.waybill_sale_id IS 'Идентификатор накладной';

COMMENT ON COLUMN public.lot_sale.lot_id IS 'Идентификатор партии';

COMMENT ON COLUMN public.lot_sale.quantity IS 'Количество изделий из партии отгруженных в накладной';

--------------------------------------------------------------------------------

CREATE TRIGGER lot_sale_aiud_0
	AFTER INSERT OR UPDATE OR DELETE ON public.lot_sale
	FOR EACH ROW
	EXECUTE PROCEDURE public.lot_sale_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.lot_sale
	ADD CONSTRAINT pk_lot_sale_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.lot_sale
	ADD CONSTRAINT unq_lot_sale UNIQUE (waybill_sale_id, lot_id);

--------------------------------------------------------------------------------

ALTER TABLE public.lot_sale
	ADD CONSTRAINT check_lot_sale_quantity CHECK ((quantity > 0));

--------------------------------------------------------------------------------

ALTER TABLE public.lot_sale
	ADD CONSTRAINT fk_lot_sale_waybill FOREIGN KEY (waybill_sale_id) REFERENCES public.waybill_sale(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.lot_sale
	ADD CONSTRAINT fk_lot_sale_lot FOREIGN KEY (lot_id) REFERENCES public.production_lot(id) ON UPDATE CASCADE ON DELETE CASCADE;
