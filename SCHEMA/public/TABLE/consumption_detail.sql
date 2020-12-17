CREATE TABLE public.consumption_detail (
	id bigint DEFAULT nextval('public.consumption_detail_id_seq'::regclass) NOT NULL,
	owner_id uuid,
	goods_id uuid,
	amount numeric(12,3) DEFAULT 0,
	product_id uuid
);

ALTER TABLE public.consumption_detail OWNER TO postgres;

GRANT ALL ON TABLE public.consumption_detail TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.consumption_detail TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.consumption_detail
	ADD CONSTRAINT pk_consumption_detail_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.consumption_detail
	ADD CONSTRAINT fk_consumption_detail_owner FOREIGN KEY (owner_id) REFERENCES public.consumption(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.consumption_detail
	ADD CONSTRAINT fk_consumption_detail_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.consumption_detail
	ADD CONSTRAINT fk_consumption_detail_product FOREIGN KEY (product_id) REFERENCES public.goods(id) ON UPDATE CASCADE;
