CREATE TABLE public.finished_goods (
	goods_id uuid NOT NULL,
	quantity numeric(12,3) DEFAULT 0 NOT NULL,
	price numeric(15,2),
	product_cost numeric(15,2)
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.finished_goods ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.finished_goods ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.finished_goods ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.finished_goods ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.finished_goods ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.finished_goods OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.finished_goods TO users;

COMMENT ON TABLE public.finished_goods IS 'Готовая продукция';

COMMENT ON COLUMN public.finished_goods.owner_id IS 'Производственная партия';

COMMENT ON COLUMN public.finished_goods.goods_id IS 'Изделие';

COMMENT ON COLUMN public.finished_goods.quantity IS 'Количество';

COMMENT ON COLUMN public.finished_goods.price IS 'Себестоимость изделия';

COMMENT ON COLUMN public.finished_goods.product_cost IS 'Общая себестоимость';

--------------------------------------------------------------------------------

CREATE TRIGGER finished_goods_ad
	AFTER DELETE ON public.finished_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER finished_goods_aiu_0
	AFTER INSERT OR UPDATE ON public.finished_goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER finished_goods_au_0
	AFTER UPDATE ON public.finished_goods
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.finished_goods_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER finished_goods_au_1
	AFTER UPDATE ON public.finished_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER finished_goods_bi
	BEFORE INSERT ON public.finished_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER finished_goods_biu_0
	BEFORE INSERT OR UPDATE ON public.finished_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.finished_goods_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER finished_goods_bu
	BEFORE UPDATE ON public.finished_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.finished_goods
	ADD CONSTRAINT fk_finished_goods_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.finished_goods
	ADD CONSTRAINT fk_finished_goods_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.finished_goods
	ADD CONSTRAINT fk_finished_goods_lot FOREIGN KEY (owner_id) REFERENCES public.production_lot(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.finished_goods
	ADD CONSTRAINT fk_finished_goods_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.finished_goods
	ADD CONSTRAINT fk_finished_goods_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.finished_goods
	ADD CONSTRAINT pk_finished_goods_id PRIMARY KEY (id);
