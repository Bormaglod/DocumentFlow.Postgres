CREATE DOMAIN public.tax_nds AS integer
	CONSTRAINT chk_tax_nds CHECK ((VALUE = ANY (ARRAY[0, 10, 20])));

ALTER DOMAIN public.tax_nds OWNER TO postgres;
