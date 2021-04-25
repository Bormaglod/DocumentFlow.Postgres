CREATE TABLE public.operation_type (
	hourly_salary numeric(15,2)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.operation_type ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.operation_type OWNER TO postgres;

GRANT ALL ON TABLE public.operation_type TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_type TO users;

--------------------------------------------------------------------------------

CREATE TRIGGER operation_type_ad
	AFTER DELETE ON public.operation_type
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER operation_type_aiu
	AFTER INSERT OR UPDATE ON public.operation_type
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_type_au_archive
	AFTER UPDATE ON public.operation_type
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.send_price_to_archive();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_type_bi
	BEFORE INSERT ON public.operation_type
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_type_bu
	BEFORE UPDATE ON public.operation_type
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER operation_type_bu_status
	BEFORE UPDATE ON public.operation_type
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_operation_type();

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT pk_operation_type_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT fk_operation_type_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT fk_operation_type_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT fk_operation_type_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT fk_operation_type_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT fk_operation_type_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_type
	ADD CONSTRAINT unq_operation_type_code UNIQUE (code);
