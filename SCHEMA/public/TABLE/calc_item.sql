CREATE TABLE public.calc_item (
	item_id uuid,
	price numeric(15,2),
	cost numeric(15,2)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.calc_item ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.calc_item OWNER TO postgres;

GRANT ALL ON TABLE public.calc_item TO admins;
GRANT SELECT ON TABLE public.calc_item TO users;

COMMENT ON COLUMN public.calc_item.price IS 'Цена за еденицу';

COMMENT ON COLUMN public.calc_item.cost IS 'Сумма';

--------------------------------------------------------------------------------

ALTER TABLE public.calc_item
	ADD CONSTRAINT pk_calculation_item_id PRIMARY KEY (id);
