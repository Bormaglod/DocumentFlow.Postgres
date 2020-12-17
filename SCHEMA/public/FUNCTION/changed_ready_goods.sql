CREATE OR REPLACE FUNCTION public.changed_ready_goods() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	r record;
	completed numeric;
	d integer;
	goods_cost money;
begin
	-- => КОРРЕКТЕН
	if (new.status_id = 1001) then
		if (new.goods_id is null) then 
			raise 'Не выбрано изделие!';
		end if;
	
		if (coalesce(new.amount, 0) <= 0) then
			raise 'Количество изделий должно быть больше 0!';
		end if;
	
		if (coalesce(new.price, 0::money) <= 0::money) then
			raise 'Цена изделия должна быть больше 0!';
		end if;
	
		if (coalesce(new.cost, 0::money) <= 0::money) then
			raise 'Стоимость готовых изделий должна быть больше 0!';
		end if;
	end if;

	-- => УТВЕРЖДЁН или УТВЕРЖДЁН => ОТМЕНЁН или ИЗМЕНЯЕТСЯ   
	if (new.status_id = 1002 or (old.status_id = 1002 and new.status_id in (1004, 1011))) then 
		if (new.owner_id is not null) then
			if (new.status_id = 1002) then
				d = 1;
			else
				d = -1;
			end if;

			for r in
				select pr.id, cio.amount 
					from production_order po 
						join production_order_detail pod on (pod.owner_id = po.id)
						join production_operation pr on (pr.owner_id = po.id)
						join calc_item_operation cio on (cio.owner_id = pod.calculation_id and pr.operation_id = cio.item_id)
						join calculation c on (c.id = pod.calculation_id)
					where po.id = new.owner_id and c.owner_id = new.goods_id and pr.goods_id = new.goods_id
			loop
				update production_operation set manufactured = coalesce(manufactured, 0) + d * r.amount * new.amount where id = r.id;
			end loop;

			select coalesce(sum(rg.amount), 0) into completed from ready_goods rg where rg.owner_id = new.owner_id and rg.status_id in (1002, 3000) and rg.goods_id = new.goods_id;
			update production_order_detail set complete_status = completed / amount * 100 where goods_id = new.goods_id and owner_id = new.owner_id;
			perform send_notify_object('production_order', new.owner_id, 'refresh');
		end if;

		if (new.status_id = 1002) then
			if (new.owner_id is null) then
				select cost into goods_cost from calculation where owner_id = new.goods_id;
			else
				select c.cost
					into goods_cost
					from production_order_detail pod 
						join calculation c on (pod.calculation_id = c.id)
					where pod.owner_id = new.owner_id and pod.goods_id = new.goods_id;
			end if;

			perform goods_balance_receipt(new.id, new.entity_kind_id, new.doc_number, new.goods_id, new.amount, goods_cost * new.amount, new.doc_date);
		else
			perform delete_balance_goods(new.id);
		end if;
	
		perform send_notify_list('balance_goods', new.goods_id, 'refresh');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_ready_goods() OWNER TO postgres;
