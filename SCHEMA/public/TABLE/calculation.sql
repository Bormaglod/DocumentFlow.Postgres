CREATE TABLE public.calculation (
	cost numeric(15,2),
	profit_percent numeric(6,2),
	profit_value numeric(15,2),
	price numeric(15,2),
	note character varying
)
INHERITS (public.directory);

ALTER TABLE ONLY public.calculation ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.calculation OWNER TO postgres;

GRANT ALL ON TABLE public.calculation TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calculation TO users;

COMMENT ON COLUMN public.calculation.cost IS 'Себестоимость';

COMMENT ON COLUMN public.calculation.profit_percent IS 'Прибыль (процент от себестоимости)';

COMMENT ON COLUMN public.calculation.profit_value IS 'Прибыль';

COMMENT ON COLUMN public.calculation.price IS 'Цена (без НДС)';

COMMENT ON COLUMN public.calculation.note IS 'Описание';

--------------------------------------------------------------------------------

CREATE INDEX unq_calculation_code ON public.calculation USING btree (owner_id, code);

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_bu_status
	BEFORE UPDATE ON public.calculation
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_calculation();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_ad
	AFTER DELETE ON public.calculation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_aiu
	AFTER INSERT OR UPDATE ON public.calculation
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_bi
	BEFORE INSERT ON public.calculation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_bu
	BEFORE UPDATE ON public.calculation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_au_status
	AFTER UPDATE ON public.calculation
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_calculation();

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT pk_calculation_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT fk_calculation_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT fk_calculation_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT fk_calculation_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT fk_calculation_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT fk_calculation_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT calculation_fk FOREIGN KEY (owner_id) REFERENCES public.goods(id) ON UPDATE CASCADE ON DELETE CASCADE;
