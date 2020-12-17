CREATE OR REPLACE FUNCTION public.delete_balance_goods(document_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	r record;
	ref_id uuid;
	new_remains numeric;
begin
	select reference_id into ref_id from balance_goods where owner_id = document_id;
	select sum(amount) into new_remains from balance_goods where reference_id = ref_id and owner_id != document_id;
	if (new_remains < 0) then
		raise 'Операция приводит к отрицательному остатку материала %. Выполнение прервано.', (select name from goods where id = ref_id); 
	end if;

	update balance_goods set status_id = 1011 where owner_id = document_id;

	for r in
		select document_date, reference_id from balance_goods where owner_id = document_id
	loop
		perform rebuild_balance_goods(r.reference_id, r.document_date);
	end loop;
	
	delete from balance_goods where owner_id = document_id;
end;
$$;

ALTER FUNCTION public.delete_balance_goods(document_id uuid) OWNER TO postgres;

COMMENT ON FUNCTION public.delete_balance_goods(document_id uuid) IS 'Удаляет данные об остатках материалов, которые были получены с помощью указанного документа
- document_id - документ создавший данные об остатках материалов';
