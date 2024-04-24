CREATE TABLE public.offsets (
	contractor_id uuid,
	transaction_amount numeric(15,2)
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.offsets ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.offsets ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.offsets ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.offsets ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.offsets ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.offsets OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.offsets TO users;

COMMENT ON TABLE public.offsets IS 'Взаимозачеты';

COMMENT ON COLUMN public.offsets.contractor_id IS 'Контрагент';

COMMENT ON COLUMN public.offsets.transaction_amount IS 'Сумма взаимозачета';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_offsets_doc_number ON public.offsets USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER offsets_ad
	AFTER DELETE ON public.offsets
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER offsets_aiu
	AFTER INSERT OR UPDATE ON public.offsets
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER offsets_au_1
	AFTER UPDATE ON public.offsets
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER offsets_bi
	BEFORE INSERT ON public.offsets
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER offsets_bu
	BEFORE UPDATE ON public.offsets
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.offsets
	ADD CONSTRAINT fk_offsets_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE RESTRICT;

--------------------------------------------------------------------------------

ALTER TABLE public.offsets
	ADD CONSTRAINT pk_offsets_id PRIMARY KEY (id);
