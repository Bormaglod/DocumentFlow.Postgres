CREATE TABLE public.calculation (
	cost_price numeric(15,2),
	profit_percent numeric(6,2),
	profit_value numeric(15,2),
	price numeric(15,2),
	note character varying,
	state public.calculation_state DEFAULT 'prepare'::public.calculation_state NOT NULL,
	stimul_type public.stimulating_value DEFAULT 'money'::public.stimulating_value NOT NULL,
	stimul_payment numeric(15,2) DEFAULT 0 NOT NULL,
	date_approval date
)
INHERITS (public.directory);

ALTER TABLE ONLY public.calculation ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.calculation ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.calculation ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.calculation ALTER COLUMN owner_id SET NOT NULL;

ALTER TABLE public.calculation OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calculation TO users;

COMMENT ON TABLE public.calculation IS 'Калькуляции';

COMMENT ON COLUMN public.calculation.owner_id IS 'Ссылка на изделие';

COMMENT ON COLUMN public.calculation.cost_price IS 'Себестоимость';

COMMENT ON COLUMN public.calculation.profit_percent IS 'Рентабельность';

COMMENT ON COLUMN public.calculation.profit_value IS 'Прибыль';

COMMENT ON COLUMN public.calculation.price IS 'Цена с учётом прибыли';

COMMENT ON COLUMN public.calculation.state IS 'Состояние калькуляции';

COMMENT ON COLUMN public.calculation.stimul_type IS 'Способ начисления стимулирующих выплат';

COMMENT ON COLUMN public.calculation.stimul_payment IS 'Стимулирующая выплата';

COMMENT ON COLUMN public.calculation.date_approval IS 'Дата утверждения';

--------------------------------------------------------------------------------

CREATE INDEX unq_calculation_code ON public.calculation USING btree (owner_id, code);

--------------------------------------------------------------------------------

CREATE INDEX idx_calculation_state ON public.calculation USING btree (state)
WHERE (state = 'approved'::public.calculation_state);

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_ad
	AFTER DELETE ON public.calculation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_aiu_0
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

CREATE TRIGGER calculation_biu_0
	BEFORE INSERT OR UPDATE ON public.calculation
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_bu
	BEFORE UPDATE ON public.calculation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_aiu_1
	AFTER INSERT OR UPDATE ON public.calculation
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_au_0
	AFTER UPDATE ON public.calculation
	FOR EACH ROW
	WHEN ((NOT (old.deleted AND new.deleted)))
	EXECUTE PROCEDURE public.calculation_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_aiu_2
	AFTER INSERT OR UPDATE ON public.calculation
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_changed();

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT pk_calculation_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT fk_calculation_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT fk_calculation_owner FOREIGN KEY (owner_id) REFERENCES public.goods(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation
	ADD CONSTRAINT fk_calculation_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
