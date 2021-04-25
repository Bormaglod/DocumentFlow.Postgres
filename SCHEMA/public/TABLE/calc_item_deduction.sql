CREATE TABLE public.calc_item_deduction (
	percentage numeric(5,2)
)
INHERITS (public.calc_item);

ALTER TABLE ONLY public.calc_item_deduction ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.calc_item_deduction OWNER TO postgres;

GRANT ALL ON TABLE public.calc_item_deduction TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calc_item_deduction TO users;

COMMENT ON COLUMN public.calc_item_deduction.cost IS 'Сумма отчисления';

COMMENT ON COLUMN public.calc_item_deduction.item_id IS 'Ссылка на характеристики отчисления (deduction)';

COMMENT ON COLUMN public.calc_item_deduction.price IS 'База для отчисления';

COMMENT ON COLUMN public.calc_item_deduction.percentage IS 'Процент от базы';

--------------------------------------------------------------------------------

CREATE INDEX unq_calc_item_deduction_item ON public.calc_item_deduction USING btree (owner_id, item_id);

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_deduction_ad
	AFTER DELETE ON public.calc_item_deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calc_item_deduction_aiu
	AFTER INSERT OR UPDATE ON public.calc_item_deduction
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_deduction_aiu_0
	AFTER INSERT OR UPDATE ON public.calc_item_deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.checking_calc_item();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_deduction_bi
	BEFORE INSERT ON public.calc_item_deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_deduction_bu
	BEFORE UPDATE ON public.calc_item_deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_deduction_bu_status
	BEFORE UPDATE ON public.calc_item_deduction
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_calc_item_deduction();

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_deduction
	ADD CONSTRAINT pk_calc_item_deduction_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_deduction
	ADD CONSTRAINT fk_calc_item_deduction_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_deduction
	ADD CONSTRAINT fk_calc_item_deduction_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_deduction
	ADD CONSTRAINT fk_calc_item_deduction_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_deduction
	ADD CONSTRAINT fk_calc_item_deduction_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_deduction
	ADD CONSTRAINT fk_calc_item_deduction_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_deduction
	ADD CONSTRAINT unq_calc_item_deduction_code UNIQUE (code);
