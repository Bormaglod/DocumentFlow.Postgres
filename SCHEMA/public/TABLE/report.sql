CREATE TABLE public.report (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	code character varying(30) NOT NULL,
	title character varying(255) NOT NULL,
	schema_report xml
);

ALTER TABLE public.report OWNER TO postgres;

GRANT SELECT ON TABLE public.report TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.report
	ADD CONSTRAINT pk_report_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.report
	ADD CONSTRAINT unq_report_code UNIQUE (code);
