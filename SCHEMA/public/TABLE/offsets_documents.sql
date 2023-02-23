CREATE TABLE public.offsets_documents (
	id bigint DEFAULT nextval('public.offsets_documents_id_seq'::regclass) NOT NULL,
	owner_id uuid,
	contract_id uuid,
	org_contract_id uuid,
	transaction_amount numeric(15,2)
);

ALTER TABLE public.offsets_documents OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.offsets_documents TO users;

COMMENT ON COLUMN public.offsets_documents.owner_id IS 'Документ "Взаимозачет"';
