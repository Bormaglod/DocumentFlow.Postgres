CREATE TABLE public.calc_item_operation (
	amount integer DEFAULT 0
)
INHERITS (public.calc_item);

ALTER TABLE ONLY public.calc_item_operation ALTER COLUMN cost SET DEFAULT 0;

ALTER TABLE ONLY public.calc_item_operation ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.calc_item_operation ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE public.calc_item_operation OWNER TO postgres;

GRANT ALL ON TABLE public.calc_item_operation TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calc_item_operation TO users;

COMMENT ON COLUMN public.calc_item_operation.amount IS 'Количество операций';

--------------------------------------------------------------------------------

CREATE INDEX unq_calc_item_operation_item ON public.calc_item_operation USING btree (owner_id, item_id);

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_operation_ad
	AFTER DELETE ON public.calc_item_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calc_item_operation_aiu
	AFTER INSERT OR UPDATE ON public.calc_item_operation
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_operation_aiu_0
	AFTER INSERT OR UPDATE ON public.calc_item_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.checking_calc_item();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_operation_bi
	BEFORE INSERT ON public.calc_item_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_operation_bu
	BEFORE UPDATE ON public.calc_item_operation
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_operation_bu_status
	BEFORE UPDATE ON public.calc_item_operation
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_calc_item_operation();

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_operation
	ADD CONSTRAINT pk_calc_item_operation_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_operation
	ADD CONSTRAINT fk_calc_item_operation_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_operation
	ADD CONSTRAINT fk_calc_item_operation_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_operation
	ADD CONSTRAINT fk_calc_item_operation_item FOREIGN KEY (item_id) REFERENCES public.operation(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_operation
	ADD CONSTRAINT fk_calc_item_operation_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_operation
	ADD CONSTRAINT fk_calc_item_operation_owner FOREIGN KEY (owner_id) REFERENCES public.calculation(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_operation
	ADD CONSTRAINT fk_calc_item_operation_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_operation
	ADD CONSTRAINT fk_calc_item_operation_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_operation
	ADD CONSTRAINT unq_calc_item_operation_code UNIQUE (code);
