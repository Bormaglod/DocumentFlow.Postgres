CREATE TABLE public.calculation_deduction (
	value numeric(15,2)
)
INHERITS (public.calculation_item);

ALTER TABLE ONLY public.calculation_deduction ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.calculation_deduction ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.calculation_deduction ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.calculation_deduction OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calculation_deduction TO users;

COMMENT ON TABLE public.calculation_deduction IS 'Список удержаний в калькуляции';

COMMENT ON COLUMN public.calculation_deduction.item_cost IS 'Сумма удержания';

COMMENT ON COLUMN public.calculation_deduction.item_id IS 'Ссылка на статью удержания (deduction)';

COMMENT ON COLUMN public.calculation_deduction.owner_id IS 'Калькуляция';

COMMENT ON COLUMN public.calculation_deduction.price IS 'База для удержания в руб. (для deduction.base = person, равна deduction.value)';

COMMENT ON COLUMN public.calculation_deduction.value IS 'Процент от базы (для deduction.base = person, всегда 100)';

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_deduction_ad
	AFTER DELETE ON public.calculation_deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_deduction_aiu
	AFTER INSERT OR UPDATE ON public.calculation_deduction
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_deduction_bi
	BEFORE INSERT ON public.calculation_deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_deduction_bu
	BEFORE UPDATE ON public.calculation_deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_deduction_biu_0
	BEFORE INSERT OR UPDATE ON public.calculation_deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_deduction_changing();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calculation_deduction_aiu_0
	AFTER INSERT OR UPDATE ON public.calculation_deduction
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_deduction_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calculation_deduction_aiu_1
	AFTER INSERT OR UPDATE ON public.calculation_deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.calculation_deduction_changed();

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_deduction
	ADD CONSTRAINT pk_calculation_deduction_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_deduction
	ADD CONSTRAINT fk_calculation_deduction_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_deduction
	ADD CONSTRAINT fk_calculation_deduction_item FOREIGN KEY (item_id) REFERENCES public.deduction(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_deduction
	ADD CONSTRAINT fk_calculation_deduction_owner FOREIGN KEY (owner_id) REFERENCES public.calculation(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_deduction
	ADD CONSTRAINT fk_calculation_deduction_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
