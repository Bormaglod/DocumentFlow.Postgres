CREATE TABLE public.contract (
	contract_type public.contract_type NOT NULL,
	tax_payer boolean DEFAULT true NOT NULL,
	is_default boolean
)
INHERITS (public.directory);

ALTER TABLE ONLY public.contract ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.contract OWNER TO postgres;

GRANT ALL ON TABLE public.contract TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.contract TO users;

COMMENT ON COLUMN public.contract.contract_type IS 'Вид договора';

COMMENT ON COLUMN public.contract.tax_payer IS 'Уплачивает НДС';

--------------------------------------------------------------------------------

CREATE TRIGGER contract_ad
	AFTER DELETE ON public.contract
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleting();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER contract_aiu
	AFTER INSERT OR UPDATE ON public.contract
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER contract_bi
	BEFORE INSERT ON public.contract
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER contract_bu
	BEFORE UPDATE ON public.contract
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT pk_contract_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT unq_contract_code UNIQUE (code);

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_entity_kind FOREIGN KEY (entity_kind_id) REFERENCES public.entity_kind(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_locked FOREIGN KEY (user_locked_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_status FOREIGN KEY (status_id) REFERENCES public.status(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.contract
	ADD CONSTRAINT fk_contract_contractor FOREIGN KEY (owner_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE CASCADE;
