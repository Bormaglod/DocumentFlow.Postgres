CREATE OR REPLACE FUNCTION public.document_deleting() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	status_s integer;
	deleted integer[];
	kind_name varchar;
begin
	select t.starting_id, t.deleted_ids, ek.code
		into status_s, deleted, kind_name
		from entity_kind ek
			join transition t on (t.id = ek.transition_id)
		where ek.id = old.entity_kind_id;
   
	if (old.status_id not in (status_s, 500) and array_position(deleted, old.status_id) is null) then
		raise 'Запись (id = %) можно удалить только в состоянии "%"',
		old.id,
		(select note from status where id = status_s);
	end if;

	delete from history where reference_id = old.id;
	delete from document_refs where owner_id = old.id;

	if (TG_TABLE_NAME in ('organization', 'contractor')) then
		delete from account where owner_id = old.id;
		delete from employee where owner_id = old.id;
	end if;

	if (TG_TABLE_NAME in ('goods', 'operation', 'operation_type')) then
		update archive_price set status_id = 1011 where status_id = 1100 and owner_id = old.id;
		delete from archive_price where owner_id = old.id;
	end if;

	if (TG_TABLE_NAME in ('payment_order', 'invoice_receipt', 'invoice_sales')) then
		delete from balance_contractor where owner_id = old.id;
	end if;

	if (TG_TABLE_NAME = 'balance_goods' and old.status_id = 1110) then
		perform rebuild_balance_goods(old.reference_id, old.document_date);
	end if;

	perform send_notify_object(kind_name, old.id, 'delete');

	return old;
end;
$$;

ALTER FUNCTION public.document_deleting() OWNER TO postgres;
