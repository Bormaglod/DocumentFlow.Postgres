CREATE TABLE public.history (
	id bigint DEFAULT nextval('public.history_id_seq'::regclass) NOT NULL,
	reference_id uuid NOT NULL,
	from_status_id integer NOT NULL,
	to_status_id integer NOT NULL,
	changed timestamp(0) with time zone NOT NULL,
	user_id uuid NOT NULL
);

ALTER TABLE public.history OWNER TO postgres;

GRANT ALL ON TABLE public.history TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.history TO users;

COMMENT ON COLUMN public.history.user_id IS 'Автор перевода состояния';

--------------------------------------------------------------------------------

CREATE INDEX idx_history_reference ON public.history USING btree (reference_id);

--------------------------------------------------------------------------------

CREATE INDEX idx_history_changed ON public.history USING btree (changed);

--------------------------------------------------------------------------------

CREATE TRIGGER history_bi
	BEFORE INSERT ON public.history
	FOR EACH ROW
	EXECUTE PROCEDURE public.history_initialize();

--------------------------------------------------------------------------------

ALTER TABLE public.history
	ADD CONSTRAINT pk_history_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.history
	ADD CONSTRAINT fk_history_from_status FOREIGN KEY (from_status_id) REFERENCES public.status(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.history
	ADD CONSTRAINT fk_history_to_status FOREIGN KEY (to_status_id) REFERENCES public.status(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.history
	ADD CONSTRAINT fk_history_user FOREIGN KEY (user_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE ON DELETE CASCADE;
