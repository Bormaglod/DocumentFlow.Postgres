CREATE OR REPLACE FUNCTION public.changing_calc_item_operation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	status_value integer;
	operation_salary numeric;
	do_update boolean;
	o_items record;
	r_goods record;
	g_items record;
	operation_amount integer;
	delta money;
begin
	select status_id into status_value from calculation where id = new.owner_id;
	if (status_value not in (1000, 1004)) then
		raise 'Калькуляция должна быть в стостянии СОСТАВЛЕН или ИЗМЕНЯЕТСЯ';
	end if;

	if (new.status_id = 1001) then
		if (new.item_id is null) then
			raise 'Выберите производственную операцию!';
		end if;
		
		new.amount = coalesce(new.amount, 0);
		if (new.amount <= 0) then
			raise 'Количество операций должно быть больше 0!';
		end if;
	
		select round(sum(um.count_by_goods / um.count_by_operation)) into operation_amount from used_material um where um.calc_item_operation_id = new.id;
		operation_amount = coalesce(operation_amount, 0);
		if (operation_amount > 0 and operation_amount != new.amount) then
			raise 'Расчётное количество операций (%) не соответствует указанному (%)', operation_amount, new.amount;
		end if;
	
		select o.salary::numeric / coalesce(m.coefficient, 1)
			into operation_salary
			from operation o 
				left join measurement m on (m.id = o.measurement_id)
			where o.id = new.item_id;
	
		do_update = false;
		if (new.price = 0::money) then
			new.price = operation_salary;
			do_update = true;
		else
			operation_salary = new.price;
		end if;
	
		if (do_update or new.cost = 0::money) then
			new.cost = operation_salary * new.amount;
		end if;
	
		for o_items in
			select um.goods_id, sum(um.count_by_goods) as goods_count
				from used_material um 
				where um.calc_item_operation_id = new.id
    			group by um.goods_id
		loop
			o_items.goods_count = coalesce(o_items.goods_count, 0);
    		if (o_items.goods_count = 0) then
    			raise 'Количество материала должно быть больше 0.';
    		end if;

    		select sum(amount) as amount, sum(uses) as uses
				into r_goods
				from calc_item_goods
				where 
					owner_id = new.owner_id and 
					item_id = o_items.goods_id and
					status_id = 1001;
			r_goods.amount = coalesce(r_goods.amount, 0);
			r_goods.uses = coalesce(r_goods.uses, 0);
		
			if (r_goods.amount = 0) then
				raise 'В списке номенклатуры не найдена запись содержащая материал %', (select name from goods where id = o_items.goods_id);
			end if;
		
			if (o_items.goods_count > r_goods.amount - r_goods.uses) then
				raise 'Слишком большое количество материала (%: %). Максимальное количество - %, остаток - %', 
					(select name from goods where id = o_items.goods_id),
					o_items.goods_count,
					r_goods.amount,
					r_goods.amount - r_goods.uses;
			end if;
		
			for g_items in
				select id, amount, uses, (amount - uses) as required
					from calc_item_goods
					where
						owner_id = new.owner_id and
						status_id = 1001 and
						uses < amount and
						item_id = o_items.goods_id
			loop
				if (o_items.goods_count <= g_items.required) then
					update calc_item_goods
						set uses = uses + o_items.goods_count
						where id = g_items.id;
					exit;
				else
					update calc_item_goods
						set uses = g_items.amount
						where id = g_items.id;
					o_items.amount = o_items.amount - g_items.required;
					if (o_items.amount <= 0) then
						exit;
					end if;
				end if;
			end loop;
		end loop;
	end if;

	if (new.status_id = 1000) then
		for o_items in
			select um.goods_id, sum(um.count_by_goods) as goods_count
				from used_material um
				where um.calc_item_operation_id = new.id
				group by um.goods_id
		loop
			for g_items in
				select id, uses
					from calc_item_goods
					where
						owner_id = new.owner_id and
						status_id = 1001 and
						uses > 0 and
						item_id = o_items.goods_id
			loop
				if (o_items.goods_count <= g_items.uses) then
					update calc_item_goods
						set uses = uses - o_items.goods_count
						where id = g_items.id;
					exit;
				else
					update calc_item_goods
						set uses = 0
						where id = g_items.id;
					o_items.goods_count = o_items.goods_count - g_items.uses;
					if (o_items.goods_count <= 0) then
						exit;
					end if;
				end if;
			end loop;
		end loop;
	end if;

	delta = new.cost - old.cost;
	for g_items in
		select cid.id
			from calc_item_deduction cid
				join deduction d on (d.id = cid.item_id)
			where
				cid.status_id = 1001 and
				cid.owner_id = new.owner_id and
				d.accrual_base = 2
	loop 
		update calc_item_deduction 
			set price = price + delta,
				cost = (price + delta) * percentage / 100
			where id = g_items.id;
	end loop;

	return new;
end;
$$;

ALTER FUNCTION public.changing_calc_item_operation() OWNER TO postgres;
