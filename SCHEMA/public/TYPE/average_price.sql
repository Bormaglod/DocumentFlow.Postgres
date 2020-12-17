CREATE TYPE public.average_price AS (
	amount numeric(12,3),
	price money,
	avg_price money
);

ALTER TYPE public.average_price OWNER TO postgres;
