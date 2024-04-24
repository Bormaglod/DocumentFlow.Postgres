CREATE TABLE public.balance (
	reference_id uuid NOT NULL,
	operation_summa numeric(15,2) DEFAULT 0 NOT NULL,
	amount numeric(12,3) DEFAULT 0 NOT NULL,
	document_type_id uuid NOT NULL
)
INHERITS (public.base_document);

ALTER TABLE ONLY public.balance ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.balance ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.balance ALTER COLUMN owner_id SET NOT NULL;

ALTER TABLE ONLY public.balance ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.balance OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.balance TO users;

COMMENT ON TABLE public.balance IS 'Остатки';

COMMENT ON COLUMN public.balance.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.balance.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.balance.owner_id IS 'Ссылка на документ который сформировал эту запись';

COMMENT ON COLUMN public.balance.reference_id IS 'Ссылка на справочник по которому считаются остатки';

COMMENT ON COLUMN public.balance.operation_summa IS 'Сумма операции';

COMMENT ON COLUMN public.balance.amount IS 'Количество';

COMMENT ON COLUMN public.balance.document_type_id IS 'Ссылка на тип документа который сформировал эту запись';

--------------------------------------------------------------------------------

ALTER TABLE public.balance
	ADD CONSTRAINT pk_balance_id PRIMARY KEY (id);
