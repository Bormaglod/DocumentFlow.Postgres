CREATE OR REPLACE FUNCTION public.delete_balance_tolling(document_id uuid, _contractor_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	r record;
	ref_id uuid;
	new_remains numeric;
begin
	select reference_id into ref_id from balance_tolling where owner_id = document_id;
	select sum(amount) into new_remains from balance_tolling where reference_id = ref_id and owner_id != document_id and contractor_id = _contractor_id;
	if (new_remains < 0) then
		raise 'Операция приводит к отрицательному остатку материала %. Выполнение прервано.', (select name from goods where id = ref_id); 
	end if;

	update balance_tolling set status_id = 1011 where owner_id = document_id;
	delete from balance_tolling where owner_id = document_id;
end;
$$;

ALTER FUNCTION public.delete_balance_tolling(document_id uuid, _contractor_id uuid) OWNER TO postgres;
