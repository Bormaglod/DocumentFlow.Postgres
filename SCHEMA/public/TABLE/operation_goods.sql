CREATE TABLE public.operation_goods (
	id bigint DEFAULT nextval('public.operation_goods_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	goods_id uuid NOT NULL
);

ALTER TABLE public.operation_goods OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.operation_goods TO users;

COMMENT ON TABLE public.operation_goods IS 'Список изделий в которых указанная операция иожет быть использована';

COMMENT ON COLUMN public.operation_goods.owner_id IS 'Производственная операция';

COMMENT ON COLUMN public.operation_goods.goods_id IS 'Изделие';

--------------------------------------------------------------------------------

ALTER TABLE public.operation_goods
	ADD CONSTRAINT fk_operation_goods_goods FOREIGN KEY (goods_id) REFERENCES public.goods(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_goods
	ADD CONSTRAINT fk_operation_goods_operation FOREIGN KEY (owner_id) REFERENCES public.operation(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.operation_goods
	ADD CONSTRAINT pk_operation_goods_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.operation_goods
	ADD CONSTRAINT unq_operation_goods UNIQUE (owner_id, goods_id);
