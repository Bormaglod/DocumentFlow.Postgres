CREATE TABLE public.adjusting_balances (
	material_id uuid NOT NULL,
	quantity numeric(12,3) DEFAULT 0 NOT NULL
)
INHERITS (public.accounting_document);

ALTER TABLE ONLY public.adjusting_balances ALTER COLUMN carried_out SET DEFAULT false;

ALTER TABLE ONLY public.adjusting_balances ALTER COLUMN deleted SET DEFAULT false;

ALTER TABLE ONLY public.adjusting_balances ALTER COLUMN id SET DEFAULT public.uuid_generate_v4();

ALTER TABLE ONLY public.adjusting_balances ALTER COLUMN re_carried_out SET DEFAULT false;

ALTER TABLE ONLY public.adjusting_balances ALTER COLUMN state_id SET DEFAULT 0;

ALTER TABLE public.adjusting_balances OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.adjusting_balances TO users;

COMMENT ON TABLE public.adjusting_balances IS 'Корректировка остатков материалов';

COMMENT ON COLUMN public.adjusting_balances.document_date IS 'Дата документа на которую определяется остаток материала';

COMMENT ON COLUMN public.adjusting_balances.material_id IS 'Материал';

COMMENT ON COLUMN public.adjusting_balances.quantity IS 'Остаток на дату документа';

--------------------------------------------------------------------------------

CREATE UNIQUE INDEX unq_adjusting_balances_doc_number ON public.adjusting_balances USING btree (EXTRACT(year FROM date((document_date AT TIME ZONE '+04'::text))), document_number);

--------------------------------------------------------------------------------

CREATE TRIGGER adjusting_balances_ad
	AFTER DELETE ON public.adjusting_balances
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_deleted();

--------------------------------------------------------------------------------

CREATE CONSTRAINT TRIGGER adjusting_balances_aiu_0
	AFTER INSERT OR UPDATE ON public.adjusting_balances
	NOT DEFERRABLE INITIALLY IMMEDIATE
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_checking();

--------------------------------------------------------------------------------

CREATE TRIGGER adjusting_balances_au_0
	AFTER UPDATE ON public.adjusting_balances
	FOR EACH ROW
	WHEN ((old.carried_out <> new.carried_out))
	EXECUTE PROCEDURE public.adjusting_balances_accept();

--------------------------------------------------------------------------------

CREATE TRIGGER adjusting_balances_au_1
	AFTER UPDATE ON public.adjusting_balances
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updated();

--------------------------------------------------------------------------------

CREATE TRIGGER adjusting_balances_bi
	BEFORE INSERT ON public.adjusting_balances
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_initialize();

--------------------------------------------------------------------------------

CREATE TRIGGER adjusting_balances_bu
	BEFORE UPDATE ON public.adjusting_balances
	FOR EACH ROW
	EXECUTE PROCEDURE public.document_updating();

--------------------------------------------------------------------------------

ALTER TABLE public.adjusting_balances
	ADD CONSTRAINT fk_adjusting_balances_created FOREIGN KEY (user_created_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.adjusting_balances
	ADD CONSTRAINT fk_adjusting_balances_material FOREIGN KEY (material_id) REFERENCES public.material(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.adjusting_balances
	ADD CONSTRAINT fk_adjusting_balances_organization FOREIGN KEY (organization_id) REFERENCES public.organization(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.adjusting_balances
	ADD CONSTRAINT fk_adjusting_balances_updated FOREIGN KEY (user_updated_id) REFERENCES public.user_alias(id) ON UPDATE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.adjusting_balances
	ADD CONSTRAINT pk_adjusting_balances_id PRIMARY KEY (id);
