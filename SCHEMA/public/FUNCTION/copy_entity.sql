CREATE OR REPLACE FUNCTION public.copy_entity(kind_id uuid, copy_id uuid) RETURNS uuid
    LANGUAGE plpgsql
    AS $$
declare
	new_id uuid;
	op_id uuid;
	r record;
begin
	new_id = uuid_nil();
	case kind_id
		-- Выполнение работ
		when get_uuid('perform_operation') then
			if (copy_id is null) then
				return uuid_nil();
			else
				insert into perform_operation (order_id, goods_id, operation_id, employee_id, amount, using_goods_id, replacing_goods_id, salary)
					select order_id, goods_id, operation_id, employee_id, amount, using_goods_id, replacing_goods_id, salary from perform_operation where id = copy_id
					returning id into new_id;
			end if;
		
		-- Операция
		when get_uuid('operation') then
			if (copy_id is null) then
				return uuid_nil();
			else
				insert into operation (name, parent_id, produced, prod_time, production_rate, type_id, length, left_cleaning, left_sweep, right_cleaning, right_sweep, measurement_id)
					select name, parent_id, produced, prod_time, production_rate, type_id, length, left_cleaning, left_sweep, right_cleaning, right_sweep, measurement_id from operation where id = copy_id
					returning id into new_id;
			end if;
		
		-- Калькуляция
		when get_uuid('calculation') then
			if (copy_id is null) then
				return uuid_nil();
			else
				insert into calculation (owner_id, code, name, cost, profit_percent, profit_value, price, note)
					select owner_id, code, name, cost, profit_percent, profit_value, price, note from calculation where id = copy_id
					returning id into new_id;
				insert into calc_item_goods (owner_id, item_id, price, cost, amount)
					select new_id, cig.item_id, g.price, g.price * cig.amount as cost, cig.amount 
						from calc_item_goods cig 
							join goods g on (g.id = cig.item_id) 
						where cig.owner_id = copy_id;

				for r in
					select cio.id, cio.item_id, o.salary / coalesce(m.coefficient, 1) as salary, o.salary * cio.amount / coalesce(m.coefficient, 1) as cost, cio.amount 
						from calc_item_operation cio 
							join operation o on (o.id = cio.item_id)
							left join measurement m on (m.id = o.measurement_id)
						where cio.owner_id = copy_id
				loop
					insert into calc_item_operation (owner_id, item_id, price, cost, amount) values (new_id, r.item_id, r.salary, r.cost, r.amount) returning id into op_id;
					insert into used_material (calc_item_operation_id, goods_id, count_by_goods, count_by_operation)
						select op_id, goods_id, count_by_goods, count_by_operation from used_material where calc_item_operation_id = r.id;
				end loop;
			
				insert into calc_item_deduction (owner_id, item_id, percentage)
					select new_id, cid.item_id, d.percentage 
						from calc_item_deduction cid 
							join deduction d on (d.id = cid.item_id)
						where cid.owner_id = copy_id;
			end if;
		else
        	-- nothing
	end case;

	if (new_id != uuid_nil()) then
		perform send_notify_object('perform_operation', new_id, 'add');
		return new_id;
	end if;

	return null;
end;
$$;

ALTER FUNCTION public.copy_entity(kind_id uuid, copy_id uuid) OWNER TO postgres;

COMMENT ON FUNCTION public.copy_entity(kind_id uuid, copy_id uuid) IS 'Функция создает новую запись и копирует в нее данные из записи с id = copy_id. Если copy_id не указано, то возвращается значение uuid_nil. В случае отсутствия возиожности копирования возвращается NULL
- kind_id - иентификатор сущности для которой должна быть найдена обработка копирования
- copy_id - идентификатор записи, копию которой надо получить';
