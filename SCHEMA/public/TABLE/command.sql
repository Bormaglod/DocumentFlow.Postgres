CREATE TABLE public.command (
	id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
	code character varying(25) NOT NULL,
	name character varying(255),
	parent_id uuid,
	picture_id uuid,
	note character varying(255),
	entity_kind_id uuid,
	script text,
	date_updated timestamp with time zone
);

ALTER TABLE public.command OWNER TO postgres;

GRANT ALL ON TABLE public.command TO admins;
GRANT SELECT ON TABLE public.command TO users;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.command TO designers;
GRANT UPDATE ON TABLE public.command TO sergio;

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_command_entity_kind_id ON public.command USING btree (entity_kind_id);

--------------------------------------------------------------------------------

CREATE TRIGGER command_bi
	BEFORE INSERT ON public.command
	FOR EACH ROW
	EXECUTE PROCEDURE public.command_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER command_bu
	BEFORE UPDATE OF script ON public.command
	FOR EACH ROW
	WHEN ((new.date_updated = old.date_updated))
	EXECUTE PROCEDURE public.command_initialize();

--------------------------------------------------------------------------------

ALTER TABLE public.command
	ADD CONSTRAINT pk_command_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.command
	ADD CONSTRAINT fk_command_parent FOREIGN KEY (parent_id) REFERENCES public.command(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.command
	ADD CONSTRAINT fk_command_picture FOREIGN KEY (picture_id) REFERENCES public.picture(id) ON UPDATE CASCADE ON DELETE SET NULL;

--------------------------------------------------------------------------------

ALTER TABLE public.command
	ADD CONSTRAINT fk_command_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE ON DELETE SET NULL;
