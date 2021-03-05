CREATE TYPE public.average_price AS (
	amount numeric(12,3),
	price numeric(15,2),
	avg_price numeric(15,2)
);

ALTER TYPE public.average_price OWNER TO postgres;
