CREATE TABLE public.balance_tolling (
	contractor_id uuid
)
INHERITS (public.balance_goods);

ALTER TABLE ONLY public.balance_tolling ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.balance_tolling ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.balance_tolling ALTER COLUMN operation_summa SET DEFAULT 0;

ALTER TABLE public.balance_tolling OWNER TO postgres;

GRANT ALL ON TABLE public.balance_tolling TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.balance_tolling TO users;

--------------------------------------------------------------------------------

CREATE TRIGGER balance_tolling_ad
	AFTER DELETE ON public.balance_tolling
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_tolling_bi
	BEFORE INSERT ON public.balance_tolling
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_tolling_bu
	BEFORE UPDATE ON public.balance_tolling
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_tolling_bu_status
	BEFORE UPDATE ON public.balance_tolling
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_balance();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_tolling_biu
	BEFORE INSERT OR UPDATE ON public.balance_tolling
	FOR EACH ROW
	EXECUTE PROCEDURE public.initialize_tolling_material();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_tolling_aiu1
	AFTER INSERT OR UPDATE ON public.balance_tolling
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_tolling_aiu0
	AFTER INSERT OR UPDATE ON public.balance_tolling
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.check_balance_goods();

--------------------------------------------------------------------------------

ALTER TABLE public.balance_tolling
	ADD CONSTRAINT pk_balance_tolling_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.balance_tolling
	ADD CONSTRAINT fk_balance_tolling_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_tolling
	ADD CONSTRAINT fk_balance_tolling_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_tolling
	ADD CONSTRAINT fk_balance_tolling_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_tolling
	ADD CONSTRAINT fk_balance_tolling_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_tolling
	ADD CONSTRAINT fk_balance_tolling_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_tolling
	ADD CONSTRAINT fk_balance_tolling_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_tolling
	ADD CONSTRAINT fk_balance_tolling_ref FOREIGN KEY (reference_id) REFERENCES public.goods(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_tolling
	ADD CONSTRAINT fk_balance_tolling_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE CASCADE;
