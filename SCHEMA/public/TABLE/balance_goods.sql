CREATE TABLE public.balance_goods (
)
INHERITS (public.balance_product);

ALTER TABLE ONLY public.balance_goods ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.balance_goods ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.balance_goods ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.balance_goods ALTER COLUMN operation_summa SET DEFAULT 0;

ALTER TABLE public.balance_goods OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.balance_goods TO users;
GRANT SELECT ON TABLE public.balance_goods TO managers;

COMMENT ON COLUMN public.balance_goods.amount IS 'Количество материала';

COMMENT ON COLUMN public.balance_goods.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.balance_goods.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.balance_goods.document_type_id IS 'Ссылка на тип документа который сформировал эту запись';

COMMENT ON COLUMN public.balance_goods.operation_summa IS 'Сумма операции';

COMMENT ON COLUMN public.balance_goods.owner_id IS 'Ссылка на документ который сформировал эту запись';

COMMENT ON COLUMN public.balance_goods.reference_id IS 'Ссылка на материал по которому считаются остатки';

--------------------------------------------------------------------------------

CREATE INDEX idx_balance_goods_owner ON public.balance_goods USING btree (owner_id);

--------------------------------------------------------------------------------

CREATE TRIGGER balance_goods_ad
	AFTER DELETE ON public.balance_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER balance_goods_aiu
	AFTER INSERT OR UPDATE ON public.balance_goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

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

CREATE CONSTRAINT TRIGGER balance_goods_aiu_0
	AFTER INSERT OR UPDATE ON public.balance_goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.balance_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER balance_goods_ad_0
	AFTER DELETE ON public.balance_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.balance_goods_deleted();

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT pk_balance_goods_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_document_type FOREIGN KEY (document_type_id) REFERENCES public.document_type(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_reference FOREIGN KEY (reference_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.balance_goods
	ADD CONSTRAINT fk_balance_goods_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON DELETE CASCADE;
