CREATE TABLE public.printed_form (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	code character varying(20) NOT NULL,
	name character varying(255) NOT NULL,
	picture_id uuid,
	schema_form jsonb,
	date_updated timestamp with time zone
);

ALTER TABLE public.printed_form OWNER TO postgres;

ALTER TABLE ONLY public.printed_form ALTER COLUMN schema_form SET STATISTICS 0;

--------------------------------------------------------------------------------

ALTER TABLE public.printed_form
	ADD CONSTRAINT pk_printed_form_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.printed_form
	ADD CONSTRAINT fk_printed_form_picture FOREIGN KEY (picture_id) REFERENCES public.picture(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.printed_form
	ADD CONSTRAINT unq_printed_form_code UNIQUE (code);
