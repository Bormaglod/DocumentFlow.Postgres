CREATE TABLE public.print_kind_form (
	id bigint DEFAULT nextval('public.print_kind_form_id_seq'::regclass) NOT NULL,
	entity_kind_id uuid NOT NULL,
	print_form_id uuid NOT NULL,
	default_form boolean DEFAULT false NOT NULL
);

ALTER TABLE public.print_kind_form OWNER TO postgres;

GRANT ALL ON TABLE public.print_kind_form TO admins;
GRANT SELECT ON TABLE public.print_kind_form TO users;

--------------------------------------------------------------------------------

ALTER TABLE public.print_kind_form
	ADD CONSTRAINT pk_print_kind_form_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.print_kind_form
	ADD CONSTRAINT fk_print_kind_form_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.print_kind_form
	ADD CONSTRAINT fk_print_kind_form_print_form FOREIGN KEY (print_form_id) REFERENCES public.print_form(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.print_kind_form
	ADD CONSTRAINT unq_print_kind_form UNIQUE (entity_kind_id, print_form_id);
