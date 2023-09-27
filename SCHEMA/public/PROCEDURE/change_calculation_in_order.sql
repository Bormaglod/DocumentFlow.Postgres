CREATE OR REPLACE PROCEDURE public.change_calculation_in_order(order_id uuid, current_calc_id uuid, new_calc_id uuid)
    LANGUAGE plpgsql
    AS $$
declare
	lot_info record;
	perf_info record;
	new_op_info record;
begin
	-- Заменим калькуляцию в заказе
	update production_order_price 
		set calculation_id = new_calc_id 
		where owner_id = order_id and calculation_id = current_calc_id;

	-- Заменим калькуляцию во всех партиях, относящихся к заказу
	for lot_info in
		select id from production_lot where owner_id = order_id and calculation_id = current_calc_id
	loop
		call set_system_value(lot_info.id, 'lock_reaccept'::system_operation);
		update production_lot 
			set calculation_id = new_calc_id
			where id = lot_info.id;
		call clear_system_value(lot_info.id);
	
		-- Во всех выполненных работах заменим опереацию из старой калькуляции на операцию из новой калькуляции.
		for perf_info in
			select 
				op.id,
				co.code,
				o.id as operation_id
			from operations_performed op
				join calculation_operation co on op.operation_id = co.id 
				join operation o on o.id = co.item_id 
			where op.owner_id = lot_info.id
		loop
			-- Данные об операции из новой калькуляции
			select 
				co.id,
				o.id as operation_id
			into
				new_op_info
			from calculation_operation co
				join operation o on o.id = co.item_id 
			where co.owner_id = new_calc_id and co.code = perf_info.code;
			
			if (new_op_info is null) then
				raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'В новой калькуляции отсутствует запись с кодом ' || perf_info.code || '.');
			end if;
		
			if (perf_info.operation_id != new_op_info.operation_id) then
				raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'В новой калькуляции запись с кодом ' || perf_info.code || ' ссылается на другую операцию.');
			end if;
		
			call set_system_value(perf_info.id, 'lock_reaccept'::system_operation);
			update operations_performed 
				set operation_id = new_op_info.id
				where id = perf_info.id;
			call clear_system_value(perf_info.id);
		end loop;
	end loop;
	
end;
$$;

ALTER PROCEDURE public.change_calculation_in_order(order_id uuid, current_calc_id uuid, new_calc_id uuid) OWNER TO postgres;

COMMENT ON PROCEDURE public.change_calculation_in_order(order_id uuid, current_calc_id uuid, new_calc_id uuid) IS 'Процедура заменяет указанную калькуляцию в заказе и во всех выполненных работах. Перепроведение документов не производится (изменяется только стоимость работы, если изменилась цена работы в калькуляции). Применять только для идентичных, по составу работ, калькуляций.';
