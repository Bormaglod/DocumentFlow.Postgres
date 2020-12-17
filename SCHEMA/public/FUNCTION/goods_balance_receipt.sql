CREATE OR REPLACE FUNCTION public.goods_balance_receipt(document_id uuid, doc_kind uuid, doc_number character varying, ref_id uuid, amount numeric, cost money, receipt_date timestamp with time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	kind_name varchar;
	b_id uuid;
	relevance_id bigint;
	r record;
begin
	if (doc_kind is null or doc_number is null) then
		select entity_kind_id, doc_number into r from document where id = document_id;
		doc_kind = coalesce(doc_kind, r.entity_kind_id);
		doc_number = coalesce(doc_number, r.doc_number);
	end if;

	select name into kind_name from entity_kind where id = doc_kind;
	insert into balance_goods (owner_id, document_date, document_name, document_number, reference_id, amount, operation_summa)
		values (document_id, receipt_date, kind_name, doc_number, ref_id, amount, cost) returning id into b_id;
	update balance_goods
		set status_id = 1111
		where id = b_id;
end;
$$;

ALTER FUNCTION public.goods_balance_receipt(document_id uuid, doc_kind uuid, doc_number character varying, ref_id uuid, amount numeric, cost money, receipt_date timestamp with time zone) OWNER TO postgres;

COMMENT ON FUNCTION public.goods_balance_receipt(document_id uuid, doc_kind uuid, doc_number character varying, ref_id uuid, amount numeric, cost money, receipt_date timestamp with time zone) IS 'Приход материала
- document_id - идентификатор документа по которому осуществляется поступление материала
- doc_kind - вид документа (может быть NULL)
- doc_number - номер документа (может быть NULL)
- ref_id - идентификатор материала
- amount - количество материала
- cost - сумма
- receipt_date - дата поступления';
