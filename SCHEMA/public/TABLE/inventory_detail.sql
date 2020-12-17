CREATE TABLE public.inventory_detail (
	id bigint DEFAULT nextval('public.inventory_detail_id_seq'::regclass) NOT NULL,
	owner_id uuid,
	goods_id uuid,
	amount numeric(12,3) DEFAULT 0
);

ALTER TABLE public.inventory_detail OWNER TO postgres;

GRANT ALL ON TABLE public.inventory_detail TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.inventory_detail TO users;

COMMENT ON COLUMN public.inventory_detail.amount IS 'Количество';

--------------------------------------------------------------------------------

ALTER TABLE public.inventory_detail
	ADD CONSTRAINT fk_inventory_detail_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.inventory_detail
	ADD CONSTRAINT pk_inventory_detail_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.inventory_detail
	ADD CONSTRAINT fk_inventory_detail_owner FOREIGN KEY (owner_id) REFERENCES public.inventory(id) ON UPDATE CASCADE ON DELETE CASCADE;
