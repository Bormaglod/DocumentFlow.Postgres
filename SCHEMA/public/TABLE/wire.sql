CREATE TABLE public.wire (
	wsize numeric(3,2) NOT NULL
)
INHERITS (public.directory);

ALTER TABLE ONLY public.wire ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.wire ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.wire ALTER COLUMN is_folder SET DEFAULT false;

ALTER TABLE public.wire OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.wire TO users;
GRANT SELECT ON TABLE public.wire TO managers;

COMMENT ON TABLE public.wire IS 'Наименование и характеристики проводов';

--------------------------------------------------------------------------------

CREATE TRIGGER wire_ad
	AFTER DELETE ON public.wire
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER wire_aiu
	AFTER INSERT OR UPDATE ON public.wire
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER wire_bi
	BEFORE INSERT ON public.wire
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER wire_bu
	BEFORE UPDATE ON public.wire
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.wire
	ADD CONSTRAINT pk_wire_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.wire
	ADD CONSTRAINT fk_wire_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.wire
	ADD CONSTRAINT fk_wire_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
