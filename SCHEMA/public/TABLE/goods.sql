CREATE TABLE public.goods (
	is_service boolean DEFAULT false NOT NULL,
	calculation_id uuid,
	note text,
	length integer,
	width integer,
	height integer
)
INHERITS (public.product);

ALTER TABLE ONLY public.goods ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.goods ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.goods ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.goods OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.goods TO users;
GRANT SELECT ON TABLE public.goods TO managers;

COMMENT ON TABLE public.goods IS 'Список производимых изделий';

COMMENT ON COLUMN public.goods.doc_name IS 'Наименование используемое в документах';

COMMENT ON COLUMN public.goods.measurement_id IS 'Единица измерения';

COMMENT ON COLUMN public.goods.price IS 'Цена продажи без НДС';

COMMENT ON COLUMN public.goods.vat IS 'Ставка НДС';

COMMENT ON COLUMN public.goods.weight IS 'Вес';

COMMENT ON COLUMN public.goods.length IS 'Длина';

COMMENT ON COLUMN public.goods.width IS 'Ширина';

COMMENT ON COLUMN public.goods.height IS 'Высота';

--------------------------------------------------------------------------------

CREATE TRIGGER goods_ad
	AFTER DELETE ON public.goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER goods_aiu
	AFTER INSERT OR UPDATE ON public.goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER goods_aiu_0
	AFTER INSERT OR UPDATE ON public.goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.goods_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER goods_bi
	BEFORE INSERT ON public.goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER goods_biu_0
	BEFORE INSERT OR UPDATE ON public.goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.goods_changing();

--------------------------------------------------------------------------------

CREATE TRIGGER goods_bu
	BEFORE UPDATE ON public.goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER goods_au_0
	AFTER UPDATE ON public.goods
	FOR EACH ROW
	WHEN ((NOT (old.deleted AND new.deleted)))
	EXECUTE PROCEDURE public.goods_mark();

--------------------------------------------------------------------------------

CREATE TRIGGER goods_au_1
	AFTER UPDATE ON public.goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.goods_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT pk_goods_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT unq_goods_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_calculation FOREIGN KEY (calculation_id) REFERENCES public.calculation(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_measurement FOREIGN KEY (measurement_id) REFERENCES public.measurement(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_parent FOREIGN KEY (parent_id) REFERENCES public.goods(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.goods
	ADD CONSTRAINT fk_goods_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
