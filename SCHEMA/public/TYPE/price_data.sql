CREATE TYPE public.price_data AS (
	id uuid,
	table_name character varying,
	amount numeric(12,3),
	product_cost numeric(15,2)
);

ALTER TYPE public.price_data OWNER TO postgres;
