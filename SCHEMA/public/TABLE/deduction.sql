CREATE TABLE public.deduction (
	accrual_base smallint DEFAULT 0,
	percentage numeric(5,2)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.deduction ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.deduction OWNER TO postgres;

GRANT ALL ON TABLE public.deduction TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.deduction TO users;

COMMENT ON COLUMN public.deduction.accrual_base IS 'База для начислений (1 - материалы, 2 - заработная плата)';

--------------------------------------------------------------------------------

CREATE TRIGGER deduction_ad
	AFTER DELETE ON public.deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER deduction_aiu
	AFTER INSERT OR UPDATE ON public.deduction
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER deduction_bi
	BEFORE INSERT ON public.deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER deduction_bu
	BEFORE UPDATE ON public.deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER deduction_au_status
	AFTER UPDATE ON public.deduction
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_deduction();

--------------------------------------------------------------------------------

ALTER TABLE public.deduction
	ADD CONSTRAINT pk_deduction_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.deduction
	ADD CONSTRAINT unq_deduction_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.deduction
	ADD CONSTRAINT fk_deduction_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.deduction
	ADD CONSTRAINT fk_deduction_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.deduction
	ADD CONSTRAINT fk_deduction_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.deduction
	ADD CONSTRAINT fk_deduction_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.deduction
	ADD CONSTRAINT fk_deduction_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.deduction
	ADD CONSTRAINT chk_deduction_accrual_base CHECK ((accrual_base = ANY (ARRAY[0, 1, 2])));

COMMENT ON CONSTRAINT chk_deduction_accrual_base ON public.deduction IS 'Неверно указана база для начисления. Допустимые значения: 0 - не установлено, 1 - материалы, 2 - заработная плата';
