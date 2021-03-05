CREATE TABLE public.ready_goods (
	goods_id uuid,
	amount numeric(12,3),
	price numeric(15,2),
	cost numeric(15,2)
)
INHERITS (public.document);

ALTER TABLE ONLY public.ready_goods ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.ready_goods OWNER TO postgres;

GRANT ALL ON TABLE public.ready_goods TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.ready_goods TO users;

COMMENT ON TABLE public.ready_goods IS 'Готовая продукция';

COMMENT ON COLUMN public.ready_goods.owner_id IS 'Заказ на изготовление';

COMMENT ON COLUMN public.ready_goods.goods_id IS 'Идентификатор готового изделия';

COMMENT ON COLUMN public.ready_goods.amount IS 'Количество';

COMMENT ON COLUMN public.ready_goods.price IS 'Цена без НДС';

COMMENT ON COLUMN public.ready_goods.cost IS 'Стоимость товара без НДС';

--------------------------------------------------------------------------------

CREATE INDEX fki_fk_ready_goods_owner ON public.ready_goods USING btree (owner_id);

--------------------------------------------------------------------------------

CREATE TRIGGER ready_goods_ad
	AFTER DELETE ON public.ready_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER ready_goods_aiu
	AFTER INSERT OR UPDATE ON public.ready_goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER ready_goods_bi
	BEFORE INSERT ON public.ready_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER ready_goods_bu
	BEFORE UPDATE ON public.ready_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER ready_goods_bu_status
	BEFORE UPDATE ON public.ready_goods
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_ready_goods();

--------------------------------------------------------------------------------

CREATE TRIGGER ready_goods_au_status
	AFTER UPDATE ON public.ready_goods
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changed_ready_goods();

--------------------------------------------------------------------------------

ALTER TABLE public.ready_goods
	ADD CONSTRAINT fk_ready_goods_owner FOREIGN KEY (owner_id) REFERENCES public.production_order(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.ready_goods
	ADD CONSTRAINT pk_ready_goods_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.ready_goods
	ADD CONSTRAINT fk_ready_goods_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.ready_goods
	ADD CONSTRAINT fk_ready_goods_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.ready_goods
	ADD CONSTRAINT fk_ready_goods_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.ready_goods
	ADD CONSTRAINT fk_ready_goods_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.ready_goods
	ADD CONSTRAINT fk_ready_goods_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.ready_goods
	ADD CONSTRAINT fk_ready_goods_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;
