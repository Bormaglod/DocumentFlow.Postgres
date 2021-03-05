CREATE TABLE public.goods (
	ext_article character varying(100),
	measurement_id uuid,
	price numeric(15,2),
	tax public.tax_nds,
	min_order numeric(15,3),
	is_service boolean,
	cross_id uuid
)
INHERITS (public.directory);

ALTER TABLE ONLY public.goods ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.goods OWNER TO postgres;

GRANT ALL ON TABLE public.goods TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.goods TO users;

COMMENT ON COLUMN public.goods.code IS 'Артикул';

COMMENT ON COLUMN public.goods.name IS 'Наименование товара, материала или услуги';

COMMENT ON COLUMN public.goods.ext_article IS 'Дополнительный артикул';

COMMENT ON COLUMN public.goods.measurement_id IS 'Еденица измерения';

COMMENT ON COLUMN public.goods.price IS 'Цена';

COMMENT ON COLUMN public.goods.tax IS 'Значение ставки НДС';

COMMENT ON COLUMN public.goods.min_order IS 'Минимальная партия заказа';

COMMENT ON COLUMN public.goods.is_service IS 'Это услуга';

COMMENT ON COLUMN public.goods.cross_id IS 'Кросс-артикул';

--------------------------------------------------------------------------------

CREATE TRIGGER goods_ad
	AFTER DELETE ON public.goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER goods_aiu
	AFTER INSERT OR UPDATE ON public.goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER goods_bi
	BEFORE INSERT ON public.goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER goods_bu
	BEFORE UPDATE ON public.goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER goods_bu_status
	BEFORE UPDATE ON public.goods
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_goods();

--------------------------------------------------------------------------------

CREATE TRIGGER goods_au_archive
	AFTER UPDATE ON public.goods
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.send_price_to_archive();

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT pk_goods_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT unq_goods_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_parent FOREIGN KEY (parent_id) REFERENCES public.goods(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_measurement FOREIGN KEY (measurement_id) REFERENCES public.measurement(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_cross FOREIGN KEY (cross_id) REFERENCES public.goods(id) ON UPDATE CASCADE ON DELETE SET NULL;
