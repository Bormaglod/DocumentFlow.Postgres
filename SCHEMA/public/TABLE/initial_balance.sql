CREATE TABLE public.initial_balance (
	reference_id uuid NOT NULL,
	operation_summa numeric(15,2) DEFAULT 0 NOT NULL,
	amount numeric(12,3) DEFAULT 0 NOT NULL
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.initial_balance ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.initial_balance ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.initial_balance OWNER TO postgres;

GRANT SELECT ON TABLE public.initial_balance TO users;

COMMENT ON COLUMN public.initial_balance.document_date IS 'Дата на которую определен остаток';

COMMENT ON COLUMN public.initial_balance.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.initial_balance.reference_id IS 'Ссылка на справочник по которому определяется начальный остаток';

COMMENT ON COLUMN public.initial_balance.operation_summa IS 'Сумма операции';

COMMENT ON COLUMN public.initial_balance.amount IS 'Количество';

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance
	ADD CONSTRAINT pk_initial_balance_id PRIMARY KEY (id);
