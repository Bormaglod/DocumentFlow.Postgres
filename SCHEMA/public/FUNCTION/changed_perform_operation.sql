CREATE OR REPLACE FUNCTION public.changed_perform_operation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	using_goods_count integer;
	using_goods_check uuid;
	r record;
	g_id uuid;
	debited numeric;
	max_op integer;
begin
	-- => КОРРЕКТЕН
	if (new.status_id = 1001) then
		if (new.order_id is null) then
			raise 'Необходимо выбрать заказ на изготовление.';
		end if;
	
		if (new.goods_id is null) then
			raise 'Необходимо выбрать изделие.';
		end if;
	
		if (new.operation_id is null) then
			raise 'Необходимо выбрать операцию.';
		end if;
	
		if (coalesce(new.amount) = 0) then
			raise 'Необходимо указать количество выполненных операций.';
		end if;
	
		if (new.using_goods_id is null) then
			select count(*)
				into using_goods_count
				from goods gp 
					join production_order_detail pod on (pod.goods_id = gp.id) 
					join calc_item_operation cio on (cio.owner_id = pod.calculation_id) 
					join used_material um on (um.calc_item_operation_id = cio.id) 
				where 
					pod.owner_id = new.order_id and 
					cio.item_id = new.operation_id and 
					gp.id = new.goods_id;
			if (using_goods_count > 0) then
				raise 'Необходимо указать материал, который должен быть использован согласно спецификации.';
			end if;
		else
			select gp.id
				into using_goods_check
				from goods gp 
					join production_order_detail pod on (pod.goods_id = gp.id) 
					join calc_item_operation cio on (cio.owner_id = pod.calculation_id) 
					join used_material um on (um.calc_item_operation_id = cio.id) 
				where 
					pod.owner_id = new.order_id and 
					cio.item_id = new.operation_id and 
					gp.id = new.goods_id and
					um.goods_id = new.using_goods_id;
			if (using_goods_check is null) then
				raise 'Материал "%" отсутствует в списке используемых материалов для выбранной операции "%"',
					(select name from goods where id = new.using_goods_id),
					(select name from operation where id = new.operation_id);
			end if;
		end if;
	
		if (new.employee_id is null) then
			raise 'Необходимо указать сотрудника выполнявшего операции.';
		end if;
	end if;

	-- => КОРРЕКТЕН
	-- ИСПРАВЛЯЕТСЯ => ВЫПОЛНЕНО
	if (new.status_id = 1001 or (old.status_id = 3102 and new.status_id = 3101)) then 
		if (new.using_goods_id is not null) then
			max_op = get_required_operations(new.order_id, new.goods_id, new.operation_id, new.using_goods_id);
			if (max_op < 0) then
				raise 'Количество операций с указанным материалом превышает максимально возможное (%)', max_op + new.amount;
			end if;
		end if;
	end if;

	-- => ВЫПОЛНЕНО или ИСПРАВЛЯЕТСЯ
	if (new.status_id in (3101, 3102)) then
		select id, status_id, amount, completed
			into r
			from production_operation
			where goods_id = new.goods_id and owner_id = new.order_id and operation_id = new.operation_id;
		
		if (r.id is null) then 
			raise 'Не найдена ни одной записи содержащей указанные данные о заказе, номенклатуре и операции.';
		end if;
	
		if (new.replacing_goods_id is not null) then
			g_id = new.replacing_goods_id;
		else
			g_id = new.using_goods_id;
		end if;
	end if;

	-- => ВЫПОЛНЕНО
	if (new.status_id = 3101) then
		update production_operation 
			set completed = completed + new.amount
			where id = r.id;
		
		if (r.completed + new.amount = r.amount) then
			-- Производственая операция => ВЫПОЛНЕНО
			update production_operation 
				set status_id = 3101
				where id = r.id;
		end if;
	
		perform send_notify_object('production_operation', r.id, 'refresh');
	
		if (new.using_goods_id is not null) then
			select um.count_by_operation * new.amount
				into debited
				from goods gp 
					join production_order_detail pod on (pod.goods_id = gp.id) 
					join calc_item_operation cio on (cio.owner_id = pod.calculation_id) 
					join used_material um on (um.calc_item_operation_id = cio.id) 
				where 
					pod.owner_id = new.order_id and 
					cio.item_id = new.operation_id and 
					gp.id = new.goods_id and
					um.goods_id = new.using_goods_id;
	
			perform goods_balance_expense(new.id, new.entity_kind_id, new.doc_number, g_id, debited, new.doc_date);
			perform send_notify_list('balance_goods', g_id, 'refresh');
		end if;
	end if;

	-- => ИСПРАВЛЯЕТСЯ
	if (new.status_id = 3102) then
		begin
			update production_operation 
				set completed = completed - new.amount
				where id = r.id;
		exception
			when check_violation then
				raise 'Часть операций уже учтена в готовой продукции. Изменение невозможно.';
		end;
		
		if (r.status_id = 3101) then
			update production_operation set status_id = 1001 where id = r.id;
		end if;
	
		perform send_notify_object('production_operation', r.id, 'refresh');
	
		perform delete_balance_goods(new.id);
		if (g_id is not null) then
			perform send_notify_list('balance_goods', g_id, 'refresh');
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_perform_operation() OWNER TO postgres;
