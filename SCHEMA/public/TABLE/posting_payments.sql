CREATE TABLE public.posting_payments (
	transaction_amount numeric(15,2),
	document_id uuid
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.posting_payments ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.posting_payments ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.posting_payments ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.posting_payments OWNER TO postgres;

GRANT SELECT ON TABLE public.posting_payments TO users;

COMMENT ON TABLE public.posting_payments IS 'Разнесение платежей по документам';

COMMENT ON COLUMN public.posting_payments.owner_id IS 'Платёжный ордер';

COMMENT ON COLUMN public.posting_payments.transaction_amount IS 'Сумма операции';

COMMENT ON COLUMN public.posting_payments.document_id IS 'Документ на который относится сумма';

--------------------------------------------------------------------------------

ALTER TABLE public.posting_payments
	ADD CONSTRAINT pk_posting_payments_id PRIMARY KEY (id);
