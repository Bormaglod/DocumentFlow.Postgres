CREATE OR REPLACE FUNCTION public.balance_goods_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	call rebuild_balance_goods(old.reference_id, old.document_date);
	call send_notify('balance_goods', old.reference_id);
	call send_notify('goods', old.reference_id, 'refresh');

	return old;
end;
$$;

ALTER FUNCTION public.balance_goods_deleted() OWNER TO postgres;
