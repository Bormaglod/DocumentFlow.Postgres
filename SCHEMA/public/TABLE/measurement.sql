CREATE TABLE public.measurement (
	abbreviation character varying(10),
	coefficient integer
)
INHERITS (public.directory);

ALTER TABLE ONLY public.measurement ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.measurement OWNER TO postgres;

GRANT ALL ON TABLE public.measurement TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.measurement TO users;

COMMENT ON TABLE public.measurement IS 'Единицы измерений';

COMMENT ON COLUMN public.measurement.abbreviation IS 'Сокращенное название единицы измерения';

--------------------------------------------------------------------------------

CREATE TRIGGER measurement_ad
	AFTER DELETE ON public.measurement
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER measurement_aiu
	AFTER INSERT OR UPDATE ON public.measurement
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER measurement_bi
	BEFORE INSERT ON public.measurement
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER measurement_bu
	BEFORE UPDATE ON public.measurement
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.measurement
	ADD CONSTRAINT pk_measurement_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.measurement
	ADD CONSTRAINT fk_measurement_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.measurement
	ADD CONSTRAINT fk_measurement_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.measurement
	ADD CONSTRAINT fk_measurement_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.measurement
	ADD CONSTRAINT fk_measurement_parent FOREIGN KEY (parent_id) REFERENCES public.measurement(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.measurement
	ADD CONSTRAINT fk_measurement_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.measurement
	ADD CONSTRAINT fk_measurement_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.measurement
	ADD CONSTRAINT unq_measurement_code UNIQUE (code);
