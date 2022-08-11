CREATE TABLE public.initial_balance_goods (
	reference_id uuid,
	operation_summa numeric(15,2) DEFAULT 0,
	amount numeric(12,3) DEFAULT 0
)
INHERITS (public.initial_balance);

ALTER TABLE ONLY public.initial_balance_goods ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance_goods ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.initial_balance_goods ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.initial_balance_goods ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE public.initial_balance_goods OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.initial_balance_goods TO users;

COMMENT ON COLUMN public.initial_balance_goods.document_date IS 'Дата на которую определен остаток';

COMMENT ON COLUMN public.initial_balance_goods.document_number IS 'Порядковый номер документа';

COMMENT ON COLUMN public.initial_balance_goods.reference_id IS 'Ссылка на справочник по которому определяется начальный остаток';

COMMENT ON COLUMN public.initial_balance_goods.operation_summa IS 'Сумма операции';

COMMENT ON COLUMN public.initial_balance_goods.amount IS 'Количество';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_initial_balance_goods_reference_id ON public.initial_balance_goods USING btree (reference_id);

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_initial_balance_goods_doc_number ON public.initial_balance_goods USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_goods_ad
	AFTER DELETE ON public.initial_balance_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER initial_balance_goods_aiu
	AFTER INSERT OR UPDATE ON public.initial_balance_goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_goods_bi
	BEFORE INSERT ON public.initial_balance_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_goods_bu
	BEFORE UPDATE ON public.initial_balance_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER initial_balance_goods_au_0
	AFTER UPDATE ON public.initial_balance_goods
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.initial_balance_product_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_goods_material_au_1
	AFTER UPDATE ON public.initial_balance_goods
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.initial_balance_product_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER initial_balance_goods_au_2
	AFTER UPDATE ON public.initial_balance_goods
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_goods
	ADD CONSTRAINT pk_initial_balance_goods_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_goods
	ADD CONSTRAINT fk_initial_balance_goods_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_goods
	ADD CONSTRAINT fk_initial_balance_goods_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_goods
	ADD CONSTRAINT fk_initial_balance_goods_reference FOREIGN KEY (reference_id) REFERENCES public.goods(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.initial_balance_goods
	ADD CONSTRAINT fk_initial_balance_goods_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;
