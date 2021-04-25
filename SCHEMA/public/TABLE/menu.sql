CREATE TABLE public.menu (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	code character varying(20) NOT NULL,
	name character varying(255),
	parent_id uuid,
	order_index integer DEFAULT 0,
	command_id uuid
);

ALTER TABLE public.menu OWNER TO postgres;

GRANT ALL ON TABLE public.menu TO admins;
GRANT SELECT ON TABLE public.menu TO users;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.menu TO designers;

--------------------------------------------------------------------------------

ALTER TABLE public.menu
	ADD CONSTRAINT pk_menu_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.menu
	ADD CONSTRAINT unq_menu_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.menu
	ADD CONSTRAINT fk_menu_command FOREIGN KEY (command_id) REFERENCES public.command(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.menu
	ADD CONSTRAINT fk_menu_parent FOREIGN KEY (parent_id) REFERENCES public.menu(id) ON UPDATE CASCADE ON DELETE CASCADE;
