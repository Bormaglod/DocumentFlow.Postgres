CREATE TABLE public.cutting (
	segment_length integer,
	left_cleaning numeric(4,1),
	left_sweep integer,
	right_cleaning numeric(4,1),
	right_sweep integer,
	program_number integer
)
INHERITS (public.operation);

ALTER TABLE ONLY public.cutting ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.cutting ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.cutting ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE ONLY public.cutting ALTER COLUMN salary SET DEFAULT 0;

ALTER TABLE public.cutting OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.cutting TO users;

COMMENT ON COLUMN public.cutting.prod_time IS 'Время за которое было произведено [produced] операций, мин';

COMMENT ON COLUMN public.cutting.produced IS 'Выработка за время [prod_time], шт.';

COMMENT ON COLUMN public.cutting.production_rate IS 'Норма выработки, шт./час';

COMMENT ON COLUMN public.cutting.salary IS 'Плата за выполнение [for_amount] ед. операции';

COMMENT ON COLUMN public.cutting.type_id IS 'Тип операции';

COMMENT ON COLUMN public.cutting.segment_length IS 'Длина провода';

COMMENT ON COLUMN public.cutting.left_cleaning IS 'Длина зачистки с начала провода';

COMMENT ON COLUMN public.cutting.left_sweep IS 'Ширина окна на которое снимается изоляция в начале провода';

COMMENT ON COLUMN public.cutting.right_cleaning IS 'Длина зачистки с конца провода';

COMMENT ON COLUMN public.cutting.right_sweep IS 'Ширина окна на которое снимается изоляция в конце провода';

COMMENT ON COLUMN public.cutting.program_number IS 'Номер программы';

--------------------------------------------------------------------------------

CREATE TRIGGER cutting_ad
	AFTER DELETE ON public.cutting
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER cutting_aiu
	AFTER INSERT OR UPDATE ON public.cutting
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER cutting_aiu_0
	AFTER INSERT OR UPDATE ON public.cutting
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.cutting_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER cutting_bi
	BEFORE INSERT ON public.cutting
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER cutting_biu_0
	BEFORE INSERT OR UPDATE ON public.cutting
	FOR EACH ROW
	EXECUTE PROCEDURE public.cutting_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER cutting_bu
	BEFORE UPDATE ON public.cutting
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.cutting
	ADD CONSTRAINT pk_cutting_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.cutting
	ADD CONSTRAINT fk_cutting_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.cutting
	ADD CONSTRAINT fk_cutting_parent FOREIGN KEY (parent_id) REFERENCES public.cutting(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.cutting
	ADD CONSTRAINT fk_cutting_type FOREIGN KEY (type_id) REFERENCES public.operation_type(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.cutting
	ADD CONSTRAINT fk_cutting_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
