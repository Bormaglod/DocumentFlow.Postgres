CREATE TABLE public.deduction (
	base_calc public.base_deduction NOT NULL,
	person_id uuid,
	value numeric(15,2)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.deduction ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.deduction ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.deduction ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.deduction OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.deduction TO users;

--------------------------------------------------------------------------------

CREATE TRIGGER deduction_ad
	AFTER DELETE ON public.deduction
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

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
	ADD CONSTRAINT fk_deduction_person FOREIGN KEY (person_id) REFERENCES public.person(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.deduction
	ADD CONSTRAINT fk_deduction_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
