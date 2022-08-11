CREATE TABLE public.income_item (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	code character varying(10) NOT NULL,
	item_name character varying(100) NOT NULL
);

ALTER TABLE public.income_item OWNER TO postgres;

GRANT SELECT ON TABLE public.income_item TO users;

COMMENT ON TABLE public.income_item IS 'Статьи доходов';

--------------------------------------------------------------------------------

ALTER TABLE public.income_item
	ADD CONSTRAINT pk_income_item_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.income_item
	ADD CONSTRAINT unq_income_item_code UNIQUE (code);
