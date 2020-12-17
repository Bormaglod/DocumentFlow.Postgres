CREATE OR REPLACE FUNCTION public.changed_consumption() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	rgoods record;
begin
	-- => УТВЕРДИТЬ
	if (new.status_id = 1002) then
		for rgoods in
			select goods_id, amount from consumption_detail where owner_id = new.id
		loop
			perform goods_balance_expense(new.id, new.entity_kind_id, new.view_number, rgoods.goods_id, rgoods.amount, new.doc_date);
			perform send_notify_list('balance_goods', rgoods.goods_id, 'refresh');
		end loop;
	end if;

	-- УТВЕРЖДЕН => ОТМЕНЕН или ИЗМЕНЯЕТСЯ
	if (old.status_id = 1002 and new.status_id in (1004, 1011)) then
		update balance_goods set status_id = 1011 where owner_id = new.id and status_id = 1111;
		delete from balance_goods where owner_id = new.id and status_id = 1011;
		perform send_notify_list('balance_goods', 'refresh');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_consumption() OWNER TO postgres;
