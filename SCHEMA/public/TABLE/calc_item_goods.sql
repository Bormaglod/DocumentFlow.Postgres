CREATE TABLE public.calc_item_goods (
	amount numeric(12,3) DEFAULT 0,
	uses numeric(12,3) DEFAULT 0,
	is_tolling boolean DEFAULT false
)
INHERITS (public.calc_item);

ALTER TABLE ONLY public.calc_item_goods ALTER COLUMN cost SET DEFAULT 0;

ALTER TABLE ONLY public.calc_item_goods ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.calc_item_goods ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE public.calc_item_goods OWNER TO postgres;

GRANT ALL ON TABLE public.calc_item_goods TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calc_item_goods TO users;

COMMENT ON COLUMN public.calc_item_goods.cost IS 'Сумма';

COMMENT ON COLUMN public.calc_item_goods.item_id IS 'Ссылка на материал (goods)';

COMMENT ON COLUMN public.calc_item_goods.price IS 'Цена за единицу материала';

COMMENT ON COLUMN public.calc_item_goods.amount IS 'Количество материала';

COMMENT ON COLUMN public.calc_item_goods.uses IS 'Использовано в операциях';

COMMENT ON COLUMN public.calc_item_goods.is_tolling IS 'Давальческий материал';

--------------------------------------------------------------------------------

CREATE INDEX unq_calc_item_goods_item ON public.calc_item_goods USING btree (owner_id, item_id);

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_goods_aiu_0
	AFTER INSERT OR UPDATE ON public.calc_item_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.checking_calc_item();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_goods_ad
	AFTER DELETE ON public.calc_item_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER calc_item_goods_aiu
	AFTER INSERT OR UPDATE ON public.calc_item_goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_goods_bi
	BEFORE INSERT ON public.calc_item_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_goods_bu
	BEFORE UPDATE ON public.calc_item_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER calc_item_goods_bu_status
	BEFORE UPDATE ON public.calc_item_goods
	FOR EACH ROW
	WHEN ((old.status_id <> new.status_id))
	EXECUTE PROCEDURE public.changing_calc_item_goods();

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_goods
	ADD CONSTRAINT unq_calc_item_goods_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_goods
	ADD CONSTRAINT pk_calc_item_goods_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_goods
	ADD CONSTRAINT fk_calc_item_goods_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_goods
	ADD CONSTRAINT fk_calc_item_goods_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_goods
	ADD CONSTRAINT fk_calc_item_goods_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_goods
	ADD CONSTRAINT fk_calc_item_goods_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_goods
	ADD CONSTRAINT fk_calc_item_goods_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_goods
	ADD CONSTRAINT fk_calc_item_goods_owner FOREIGN KEY (owner_id) REFERENCES public.calculation(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item_goods
	ADD CONSTRAINT fk_calc_item_goods_item FOREIGN KEY (item_id) REFERENCES public.goods(id) ON UPDATE CASCADE;
