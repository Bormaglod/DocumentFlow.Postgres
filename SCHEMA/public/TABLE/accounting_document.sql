CREATE TABLE public.accounting_document (
	carried_out boolean DEFAULT false NOT NULL,
	re_carried_out boolean DEFAULT false NOT NULL
)
INHERITS (public.base_document);

ALTER TABLE ONLY public.accounting_document ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.accounting_document ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.accounting_document OWNER TO postgres;

GRANT SELECT ON TABLE public.accounting_document TO users;

COMMENT ON TABLE public.accounting_document IS 'Все бухгалтерские документы';

COMMENT ON COLUMN public.accounting_document.document_date IS 'Дата получения документа';

COMMENT ON COLUMN public.accounting_document.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.accounting_document.carried_out IS 'Проведен или нет документ';

COMMENT ON COLUMN public.accounting_document.re_carried_out IS 'Требуется повторное проведение (или нет)';

--------------------------------------------------------------------------------

ALTER TABLE public.accounting_document
	ADD CONSTRAINT pk_accounting_document_id PRIMARY KEY (id);
