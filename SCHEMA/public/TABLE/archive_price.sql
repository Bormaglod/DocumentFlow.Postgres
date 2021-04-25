CREATE TABLE public.archive_price (
	price_value numeric(15,2),
	date_to timestamp with time zone
)
INHERITS (public.directory);

ALTER TABLE ONLY public.archive_price ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.archive_price OWNER TO postgres;

GRANT ALL ON TABLE public.archive_price TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.archive_price TO users;

COMMENT ON TABLE public.archive_price IS 'История изменения цен';

COMMENT ON COLUMN public.archive_price.date_to IS 'Дата окончания действия цены (или null, если бессрочно) (не входит в диапазон действия цены)';

--------------------------------------------------------------------------------

CREATE INDEX idx_archive_price_owner ON public.archive_price USING btree (owner_id, user_created_id);

--------------------------------------------------------------------------------

CREATE TRIGGER archive_price_ad
	AFTER DELETE ON public.archive_price
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER archive_price_aiu
	AFTER INSERT OR UPDATE ON public.archive_price
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER archive_price_bi
	BEFORE INSERT ON public.archive_price
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER archive_price_bu_0
	BEFORE UPDATE ON public.archive_price
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE TRIGGER archive_price_bu_1
	BEFORE UPDATE ON public.archive_price
	FOR EACH ROW
	EXECUTE PROCEDURE public.update_date_ranges();

--------------------------------------------------------------------------------

ALTER TABLE public.archive_price
	ADD CONSTRAINT pk_archive_price_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.archive_price
	ADD CONSTRAINT unq_archive_price_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.archive_price
	ADD CONSTRAINT fk_archive_price_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.archive_price
	ADD CONSTRAINT fk_archive_price_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.archive_price
	ADD CONSTRAINT fk_archive_price_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.archive_price
	ADD CONSTRAINT fk_archive_price_parent FOREIGN KEY (parent_id) REFERENCES public.archive_price(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.archive_price
	ADD CONSTRAINT fk_archive_price_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.archive_price
	ADD CONSTRAINT fk_archive_price_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
