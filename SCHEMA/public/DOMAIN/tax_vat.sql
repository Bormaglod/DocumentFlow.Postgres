CREATE DOMAIN public.tax_vat AS integer
	CONSTRAINT tax_vat_check CHECK ((VALUE = ANY (ARRAY[0, 10, 20])));

ALTER DOMAIN public.tax_vat OWNER TO postgres;
