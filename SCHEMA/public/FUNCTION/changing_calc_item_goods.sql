CREATE OR REPLACE FUNCTION public.changing_calc_item_goods() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	status_value integer;
	goods_price money;
	do_update boolean;
	r_item record;
	delta money;
begin
	select status_id into status_value from calculation where id = new.owner_id;
	if (status_value not in (1000, 1004)) then
		raise 'Калькуляция должна быть в стостянии СОСТАВЛЕН или ИЗМЕНЯЕТСЯ';
	end if;

	if (new.status_id = 1001) then
		if (new.item_id is null) then
			raise 'Выберите материал!';
		end if;
		
		new.amount = coalesce(new.amount, 0);
		if (new.amount <= 0) then
			raise 'Количество материала должно быть больше 0!';
		end if;
	
		if (new.is_tolling) then
			new.price = 0::money;
			new.cost = 0::money;
		else
			select price into goods_price from goods where id = new.item_id;

			do_update = false;
			if (new.price = 0::money) then
				new.price = goods_price;
				do_update = true;
			end if;
	
			if (do_update or new.cost = 0::money) then
				new.cost = new.price * new.amount;
			end if;
		end if;
	end if;

	if (new.status_id = 1000) then
		if (new.uses > 0) then
			raise 'Материал используется в одной или нескольких операциях. Перевод невозможен!';
		end if;
	end if;

	delta = new.cost - old.cost;
	for r_item in
		select cid.id
			from calc_item_deduction cid
				join deduction d on (d.id = cid.item_id)
			where
				cid.status_id = 1001 and
				cid.owner_id = new.owner_id and
				d.accrual_base = 1
	loop 
		update calc_item_deduction 
			set price = price + delta,
				cost = (price + delta) * percentage / 100
			where id = r_item.id;
	end loop;

	return new;
end;
$$;

ALTER FUNCTION public.changing_calc_item_goods() OWNER TO postgres;
