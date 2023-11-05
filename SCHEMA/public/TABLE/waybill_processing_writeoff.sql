CREATE TABLE public.waybill_processing_writeoff (
	id bigint DEFAULT nextval('public.waybill_processing_writeoff_id_seq'::regclass) NOT NULL,
	operation_write_off_id uuid NOT NULL,
	waybill_processing_id uuid NOT NULL,
	material_id uuid NOT NULL,
	amount numeric(12,3) DEFAULT 0 NOT NULL,
	write_off public.write_off_method DEFAULT 'consumption'::public.write_off_method NOT NULL
);

ALTER TABLE public.waybill_processing_writeoff OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.waybill_processing_writeoff TO users;

COMMENT ON TABLE public.waybill_processing_writeoff IS 'Списание давальческого материала';

COMMENT ON COLUMN public.waybill_processing_writeoff.operation_write_off_id IS 'Операция предпринявшая списание материала (любой документ допускающий списание)';

COMMENT ON COLUMN public.waybill_processing_writeoff.waybill_processing_id IS 'Документ о поступлении давальческого материала';

COMMENT ON COLUMN public.waybill_processing_writeoff.material_id IS 'Давальческий материал';

COMMENT ON COLUMN public.waybill_processing_writeoff.amount IS 'Количество списываемого материала';

COMMENT ON COLUMN public.waybill_processing_writeoff.write_off IS 'Способ списания материалов (расход в производстве или возврат)';

--------------------------------------------------------------------------------

CREATE INDEX idx_waybill_processing_writeoff_operation_write_off_id ON public.waybill_processing_writeoff USING btree (operation_write_off_id);

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing_writeoff
	ADD CONSTRAINT pk_waybill_processing_writeoff_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing_writeoff
	ADD CONSTRAINT fk_waybill_processing_writeoff_waybill FOREIGN KEY (waybill_processing_id) REFERENCES public.waybill_processing(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.waybill_processing_writeoff
	ADD CONSTRAINT fk_waybill_processing_writeoff_material FOREIGN KEY (material_id) REFERENCES public.material(id) ON UPDATE CASCADE ON DELETE RESTRICT;
