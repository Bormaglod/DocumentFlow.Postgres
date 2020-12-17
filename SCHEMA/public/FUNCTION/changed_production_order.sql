CREATE OR REPLACE FUNCTION public.changed_production_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	detail_count integer;
	goods_name varchar;
	rec record;
	calc_id uuid;
	op_id uuid;
begin
	-- => КОРРЕКТЕН
	if (new.status_id = 1001) then
		if (new.contractor_id is null) then
			raise 'Необходимо выбрать контрагента!';
		end if;
	
		select count(*) into detail_count from production_order_detail where owner_id = new.id;
		if (detail_count = 0) then
			raise 'Заказ не заполнен!';
		end if;
	
		if (exists(select * from production_order_detail where owner_id = new.id and goods_id is null)) then 
			raise 'Необходимо указать заказанные изделия!';
		end if;
	
		select g.name into goods_name from production_order_detail pod join goods g on (pod.goods_id = g.id) where pod.amount = 0 and pod.owner_id = new.id;
		if (goods_name is not null) then
			raise 'Для "%" необходимо указать количество.', goods_name;
		end if;
	
		for rec in
			select pod.id, g.name, pod.goods_id, pod.calculation_id 
				from production_order_detail pod 
					join goods g on (pod.goods_id = g.id) 
				where 
					pod.owner_id = new.id and 
					pod.calculation_id is null
		loop
			select id into calc_id from calculation where owner_id = rec.goods_id and status_id = 1002;
			if (calc_id is null) then
				raise 'Для "%" не выбрана калькуляция используемая для изготовления!', rec.name;
			end if;
		
			update production_order_detail set calculation_id = calc_id where id = rec.id;
		end loop;
	end if;

	-- => В ПРОИЗВОДСТВЕ
	if (new.status_id = 3100) then
		perform fill_production_operations(new.id);
		perform send_notify_list('production_operation', new.id, 'refresh');
	end if;

	-- В ПРОИЗВОДСТВЕ => ОТМЕНЕН
	if (old.status_id = 3100 and new.status_id = 1011) then 
		if (exists(select * from production_operation where owner_id = new.id and (status_id = 3101 or completed > 0))) then 
			raise 'Заказ невозможно отменить, т.к. имеются выполненные или находящиеся в процессе работы производственные операции!';
		end if;
	
		update production_operation
			set status_id = 1011
			where owner_id = new.id and status_id = 1001;
		
		perform send_notify_list('production_operation', new.id, 'refresh');
	
		update perform_operation set status_id = 1011 where order_id = new.id;
		perform send_notify_list('perform_operation', 'refresh');
	end if;

	-- В ПРОИЗВОДСТВЕ => ЗАКРЫТ
	if (old.status_id = 3100 and new.status_id = 3000) then
		if (exists(select * from production_operation where owner_id = new.id and completed != manufactured)) then
			raise 'Заказ содержит выполненные производственные операции не отражённые в готовой продукции. Закрыть заказ невозможно.';
		end if;
		
		update ready_goods set status_id = 3000 where owner_id = new.id;
		perform send_notify_list('ready_goods', new.id, 'refresh');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_production_order() OWNER TO postgres;

COMMENT ON FUNCTION public.changed_production_order() IS 'Заказ на изготовление - после изменения состояния';
