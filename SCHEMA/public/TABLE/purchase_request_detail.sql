CREATE TABLE public.purchase_request_detail (
)
INHERITS (public.goods_price_detail);

ALTER TABLE ONLY public.purchase_request_detail ALTER COLUMN amount SET DEFAULT 0;

ALTER TABLE ONLY public.purchase_request_detail ALTER COLUMN cost SET DEFAULT 0;

ALTER TABLE ONLY public.purchase_request_detail ALTER COLUMN cost_with_tax SET DEFAULT 0;

ALTER TABLE ONLY public.purchase_request_detail ALTER COLUMN id SET DEFAULT nextval('public.goods_price_detail_id_seq'::regclass);

ALTER TABLE ONLY public.purchase_request_detail ALTER COLUMN price SET DEFAULT 0;

ALTER TABLE ONLY public.purchase_request_detail ALTER COLUMN tax SET DEFAULT 20;

ALTER TABLE ONLY public.purchase_request_detail ALTER COLUMN tax_value SET DEFAULT 0;

ALTER TABLE public.purchase_request_detail OWNER TO postgres;

GRANT ALL ON TABLE public.purchase_request_detail TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.purchase_request_detail TO users;

COMMENT ON COLUMN public.purchase_request_detail.amount IS 'Количество';

COMMENT ON COLUMN public.purchase_request_detail.cost IS 'Стоимость товара без НДС';

COMMENT ON COLUMN public.purchase_request_detail.cost_with_tax IS 'Всего с НДС';

COMMENT ON COLUMN public.purchase_request_detail.goods_id IS 'Идентификатор заказанного иатериала';

COMMENT ON COLUMN public.purchase_request_detail.owner_id IS 'Идентификатор заказа на закупку';

COMMENT ON COLUMN public.purchase_request_detail.price IS 'Цена без НДС';

COMMENT ON COLUMN public.purchase_request_detail.tax IS 'Ставка НДС';

COMMENT ON COLUMN public.purchase_request_detail.tax_value IS 'Сумма НДС';

--------------------------------------------------------------------------------

CREATE INDEX fki_fk_purchase_request_detail_owner ON public.purchase_request_detail USING btree (owner_id);

--------------------------------------------------------------------------------

CREATE INDEX fki_fk_purchase_request_detail_goods ON public.purchase_request_detail USING btree (goods_id);

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request_detail
	ADD CONSTRAINT pk_purchase_request_detail_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request_detail
	ADD CONSTRAINT fk_purchase_request_detail_owner FOREIGN KEY (owner_id) REFERENCES public.purchase_request(id) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;

--------------------------------------------------------------------------------

ALTER TABLE public.purchase_request_detail
	ADD CONSTRAINT fk_purchase_request_detail_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON DELETE CASCADE NOT VALID;
