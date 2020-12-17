CREATE TABLE public.balance_contractor (
)
INHERITS (public.balance);

ALTER TABLE ONLY public.balance_contractor ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.balance_contractor ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.balance_contractor ALTER COLUMN operation_summa SET DEFAULT 0;

ALTER TABLE public.balance_contractor OWNER TO postgres;

GRANT ALL ON TABLE public.balance_contractor TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.balance_contractor TO users;

COMMENT ON COLUMN public.balance_contractor.amount IS 'Количество';

COMMENT ON COLUMN public.balance_contractor.document_date IS 'Дата/время внесения изменения (дата документа из поля owber_id)';

COMMENT ON COLUMN public.balance_contractor.document_name IS 'Наименование документа внесшего изменения (тип документа на который ссылается owner_id)';

COMMENT ON COLUMN public.balance_contractor.document_number IS 'Номер документа внесшего изменения';

COMMENT ON COLUMN public.balance_contractor.operation_summa IS 'Сумма операции (положительное значение - приход, иначе - расход)';

COMMENT ON COLUMN public.balance_contractor.reference_id IS 'Ссылка на контрагента по которому считаются остатки';

--------------------------------------------------------------------------------

CREATE INDEX fki_fk_balance_contractor_ref ON public.balance_contractor USING btree (reference_id);

--------------------------------------------------------------------------------

CREATE TRIGGER balance_contractor_ad
	AFTER DELETE ON public.balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_contractor_aiu
	AFTER INSERT OR UPDATE ON public.balance_contractor
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_contractor_bi
	BEFORE INSERT ON public.balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_contractor_bu
	BEFORE UPDATE ON public.balance_contractor
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_contractor_bu_status
	BEFORE UPDATE ON public.balance_contractor
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_balance();

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT pk_balance_contractor_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_contractor
	ADD CONSTRAINT fk_balance_contractor_ref FOREIGN KEY (reference_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
