CREATE OR REPLACE FUNCTION public.goods_balance_expense(document_id uuid, doc_kind uuid, doc_number character varying, ref_id uuid, goods_amount numeric, expense_date timestamp with time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	kind_name varchar;
	b_id uuid;
	relevance_id bigint;
	remainder numeric;
	kind_rec record;
	avg_price average_price;
begin
	goods_amount = coalesce(goods_amount, 0);
	expense_date = coalesce(expense_date, now());
	remainder = get_goods_remainder(ref_id, expense_date);
	if (remainder < goods_amount) then
		raise 'Требуется материал % в количестве %. В наличии имеется - %.', 
			(select name from goods where id = ref_id),
			goods_amount,
			remainder;
	end if;

	if (doc_kind is null or doc_number is null) then
		select entity_kind_id, doc_number into kind_rec from document where id = document_id;
		doc_kind = coalesce(doc_kind, kind_rec.entity_kind_id);
		doc_number = coalesce(doc_number, kind_rec.doc_number);
	end if;

	avg_price = get_average_price(ref_id, expense_date, goods_amount);

	select name into kind_name from entity_kind where id = doc_kind;
	insert into balance_goods (owner_id, document_date, document_name, document_number, reference_id, amount, operation_summa)
		values (document_id, expense_date, kind_name, doc_number, ref_id, goods_amount, 0::money - avg_price.price) returning id into b_id;
	update balance_goods
		set status_id = 1111
		where id = b_id;
end;
$$;

ALTER FUNCTION public.goods_balance_expense(document_id uuid, doc_kind uuid, doc_number character varying, ref_id uuid, goods_amount numeric, expense_date timestamp with time zone) OWNER TO postgres;

COMMENT ON FUNCTION public.goods_balance_expense(document_id uuid, doc_kind uuid, doc_number character varying, ref_id uuid, goods_amount numeric, expense_date timestamp with time zone) IS 'Расход материала
- document_id - идентификатор документа по которому осуществляется расход материала
- doc_kind - вид документа (может быть NULL)
- doc_number - номер документа (может быть NULL)
- ref_id - идентификатор материала
- goods_amount - количество материала
- expense_date - дата расхода';
