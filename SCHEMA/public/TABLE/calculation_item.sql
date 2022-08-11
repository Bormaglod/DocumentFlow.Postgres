CREATE TABLE public.calculation_item (
	item_id uuid,
	price numeric(15,4),
	item_cost numeric(15,2)
)
INHERITS (public.directory);

ALTER TABLE ONLY public.calculation_item ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.calculation_item ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.calculation_item ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.calculation_item OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.calculation_item TO users;

COMMENT ON TABLE public.calculation_item IS 'Элемент калькуляции';

COMMENT ON COLUMN public.calculation_item.owner_id IS 'Калькуляция';

--------------------------------------------------------------------------------

ALTER TABLE public.calculation_item
	ADD CONSTRAINT pk_calculation_item_id PRIMARY KEY (id);
