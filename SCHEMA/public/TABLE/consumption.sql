CREATE TABLE public.consumption (
	employee_id uuid
)
INHERITS (public.document);

ALTER TABLE ONLY public.consumption ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.consumption OWNER TO postgres;

GRANT ALL ON TABLE public.consumption TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.consumption TO users;

COMMENT ON TABLE public.consumption IS 'Требование-накладная (расход материалов  в производстве и на накладные расходы)';

--------------------------------------------------------------------------------

CREATE TRIGGER consumption_ad
	AFTER DELETE ON public.consumption
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER consumption_aiu
	AFTER INSERT OR UPDATE ON public.consumption
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER consumption_bi
	BEFORE INSERT ON public.consumption
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER consumption_bu
	BEFORE UPDATE ON public.consumption
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER consumption_au_status
	AFTER UPDATE ON public.consumption
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_consumption();

--------------------------------------------------------------------------------

CREATE TRIGGER consumption_bu_status
	BEFORE UPDATE ON public.consumption
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_consumption();

--------------------------------------------------------------------------------

ALTER TABLE public.consumption
	ADD CONSTRAINT pk_consumption_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.consumption
	ADD CONSTRAINT fk_consumption_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.consumption
	ADD CONSTRAINT fk_consumption_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.consumption
	ADD CONSTRAINT fk_consumption_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.consumption
	ADD CONSTRAINT fk_consumption_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.consumption
	ADD CONSTRAINT fk_consumption_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.consumption
	ADD CONSTRAINT fk_consumption_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.consumption
	ADD CONSTRAINT fk_consumption_employee FOREIGN KEY (employee_id) REFERENCES public.employee(id) ON UPDATE CASCADE;
