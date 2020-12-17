CREATE TABLE public.company (
	short_name character varying(50),
	full_name character varying(150),
	inn numeric(12,0),
	kpp numeric(9,0),
	ogrn numeric(13,0),
	okpo numeric(8,0),
	okopf_id uuid,
	account_id uuid
)
INHERITS (public.directory);

ALTER TABLE ONLY public.company ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE public.company OWNER TO postgres;

GRANT ALL ON TABLE public.company TO admins;
GRANT SELECT ON TABLE public.company TO users;

COMMENT ON COLUMN public.company.short_name IS 'Краткое наименование';

COMMENT ON COLUMN public.company.full_name IS 'Полное наименование';

COMMENT ON COLUMN public.company.inn IS 'Индивидуальный номер налогоплателщика';

COMMENT ON COLUMN public.company.kpp IS 'Код причины постановки на учет';

COMMENT ON COLUMN public.company.ogrn IS 'Основной государственный регистрационный номер';

COMMENT ON COLUMN public.company.okpo IS 'Общероссийский классификатор предприятий и организаций';

--------------------------------------------------------------------------------

ALTER TABLE public.company
	ADD CONSTRAINT pk_company_id PRIMARY KEY (id);
