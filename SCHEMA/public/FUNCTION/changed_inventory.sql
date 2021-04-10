CREATE OR REPLACE FUNCTION public.changed_inventory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	rgoods record;
	ap average_price;
	b_id uuid;
	kind_name varchar;
	goods_price numeric;
begin
	-- => УТВЕРДИТЬ
	if (new.status_id = 1002) then
		select name into kind_name from entity_kind where id = new.entity_kind_id;
		for rgoods in
			select goods_id, amount from inventory_detail where owner_id = new.id
		loop
			ap = get_average_price(rgoods.goods_id, new.doc_date);
			
			if (ap.avg_price = 0) then
				select price into goods_price from goods where id = rgoods.goods_id;
			else
				goods_price = ap.avg_price;
			end if;
		
			rgoods.amount = rgoods.amount - ap.amount;
		
			insert into balance_goods (owner_id, document_date, document_name, document_number, reference_id, amount, operation_summa, document_kind)
				values (new.id, new.doc_date, kind_name, new.doc_number, rgoods.goods_id, rgoods.amount, abs(goods_price * rgoods.amount), new.entity_kind_id) returning id into b_id;
			update balance_goods
				set status_id = 1112
				where id = b_id;
		
			perform send_notify_list('balance_goods', rgoods.goods_id, 'refresh');
		end loop;
	end if;

	-- УТВЕРЖДЕН => ОТМЕНЕН или ИЗМЕНЯЕТСЯ
	if (old.status_id = 1002 and new.status_id in (1004, 1011)) then
		update balance_goods set status_id = 1011 where owner_id = new.id and status_id = 1112;
		delete from balance_goods where owner_id = new.id and status_id = 1011;
		perform send_notify_list('balance_goods', 'refresh');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_inventory() OWNER TO postgres;
