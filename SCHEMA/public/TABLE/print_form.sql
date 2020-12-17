CREATE TABLE public.print_form (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	name character varying(255) NOT NULL,
	picture_id uuid,
	form_text xml,
	properties jsonb
);

ALTER TABLE public.print_form OWNER TO postgres;

GRANT ALL ON TABLE public.print_form TO admins;
GRANT SELECT ON TABLE public.print_form TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.print_form
	ADD CONSTRAINT pk_print_form_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.print_form
	ADD CONSTRAINT fk_print_form_picture FOREIGN KEY (picture_id) REFERENCES public.picture(id) ON UPDATE CASCADE ON DELETE SET NULL;
