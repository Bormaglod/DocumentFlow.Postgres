CREATE TABLE public.balance (
	document_date timestamp(0) with time zone,
	document_name character varying(40),
	document_number character varying(20),
	reference_id uuid,
	operation_summa numeric(15,2) DEFAULT 0,
	amount numeric(12,3) DEFAULT 0,
	document_kind uuid
)
INHERITS (public.document);

ALTER TABLE ONLY public.balance ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.balance OWNER TO postgres;

GRANT ALL ON TABLE public.balance TO admins;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.balance TO users;

COMMENT ON COLUMN public.balance.document_date IS 'Дата/время внесения изменения (дата документа из поля owber_id)';

COMMENT ON COLUMN public.balance.document_name IS 'Наименование документа внесшего изменения (тип документа на который ссылается owner_id)';

COMMENT ON COLUMN public.balance.document_number IS 'Номер документа внесшего изменения';

COMMENT ON COLUMN public.balance.reference_id IS 'Ссылка на справочник по которому считаются остатки';

COMMENT ON COLUMN public.balance.operation_summa IS 'Сумма операции (положительное значение - приход, иначе - расход)';

COMMENT ON COLUMN public.balance.amount IS 'Количество';
