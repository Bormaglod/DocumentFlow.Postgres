CREATE TABLE public.operation_goods (
	id bigint DEFAULT nextval('public.operation_goods_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	goods_id uuid NOT NULL
);

ALTER TABLE public.operation_goods OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_goods TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_goods
	ADD CONSTRAINT pk_operation_goods_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.operation_goods
	ADD CONSTRAINT unq_operation_goods UNIQUE (owner_id, goods_id);

--------------------------------------------------------------------------------

ALTER TABLE public.operation_goods
	ADD CONSTRAINT fk_operation_goods_operation FOREIGN KEY (owner_id) REFERENCES public.operation(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_goods
	ADD CONSTRAINT fk_operation_goods_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE ON DELETE CASCADE;