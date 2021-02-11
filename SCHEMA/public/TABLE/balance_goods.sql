CREATE TABLE public.balance_goods (
)
INHERITS (public.balance);

ALTER TABLE ONLY public.balance_goods ALTER COLUMN amount SET NOT NULL;

ALTER TABLE ONLY public.balance_goods ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.balance_goods ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.balance_goods ALTER COLUMN operation_summa SET NOT NULL;

ALTER TABLE ONLY public.balance_goods ALTER COLUMN operation_summa SET DEFAULT 0;

ALTER TABLE ONLY public.balance_goods ALTER COLUMN reference_id SET NOT NULL;

ALTER TABLE public.balance_goods OWNER TO postgres;

GRANT ALL ON TABLE public.balance_goods TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.balance_goods TO users;

COMMENT ON COLUMN public.balance_goods.amount IS 'Количество';

COMMENT ON COLUMN public.balance_goods.document_date IS 'Дата/время внесения изменения (дата документа из поля owber_id)';

COMMENT ON COLUMN public.balance_goods.document_name IS 'Наименование документа внесшего изменения (тип документа на который ссылается owner_id)';

COMMENT ON COLUMN public.balance_goods.document_number IS 'Номер документа внесшего изменения';

COMMENT ON COLUMN public.balance_goods.operation_summa IS 'Сумма операции (положительное значение - приход, иначе - расход)';

COMMENT ON COLUMN public.balance_goods.owner_id IS 'Документ внёсший изменения';

COMMENT ON COLUMN public.balance_goods.reference_id IS 'Ссылка на материал по которому считаются остатки';

--------------------------------------------------------------------------------

CREATE INDEX fki_fk_balance_goods_ref ON public.balance_goods USING btree (reference_id);

--------------------------------------------------------------------------------

CREATE INDEX idx_balance_goods_owner_id ON public.balance_goods USING btree (owner_id);

--------------------------------------------------------------------------------

CREATE TRIGGER balance_goods_ad
	AFTER DELETE ON public.balance_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_goods_bi
	BEFORE INSERT ON public.balance_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_goods_bu
	BEFORE UPDATE ON public.balance_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_goods_bu_status
	BEFORE UPDATE ON public.balance_goods
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_balance();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_goods_au_status
	AFTER UPDATE ON public.balance_goods
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_balance();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_goods_aiu1
	AFTER INSERT OR UPDATE ON public.balance_goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_goods_aiu0
	AFTER INSERT OR UPDATE ON public.balance_goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.check_balance_goods();

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT pk_balance_goods_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_ref FOREIGN KEY (reference_id) REFERENCES public.goods(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT unq_balance_goods_reference UNIQUE (owner_id, reference_id);

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_document FOREIGN KEY (document_kind) REFERENCES public.entity_kind(id) ON UPDATE CASCADE ON DELETE CASCADE;
