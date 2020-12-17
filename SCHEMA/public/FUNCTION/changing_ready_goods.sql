CREATE OR REPLACE FUNCTION public.changing_ready_goods() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	need_calc boolean;
	already_complete numeric;
begin
	-- => КОРРЕКТЕН
	if (new.status_id = 1001) then
		need_calc = false;
		if (coalesce(new.price, 0::money) = 0::money) then
			if (new.owner_id is null) then
				select g.price into new.price from goods g where g.id = new.goods_id;
			else
				select pod.price into new.price from production_order_detail pod where pod.owner_id = new.owner_id and pod.goods_id = new.goods_id;
			end if;
		
			need_calc = true;
		end if;
	
		new.amount = coalesce(new.amount, 0);
		if ((new.owner_id is not null) and (new.amount = 0)) then
			select min(pr.completed / cio.amount) 
				into new.amount
				from production_order po 
					join production_order_detail pod on (pod.owner_id = po.id)
					join production_operation pr on (pr.owner_id = po.id)
					join calc_item_operation cio on (cio.owner_id = pod.calculation_id and pr.operation_id = cio.item_id)
					join calculation c on (c.id = pod.calculation_id)
				where po.id = new.owner_id and c.owner_id = new.goods_id and pr.goods_id = new.goods_id;
			
			select coalesce(sum(rg.amount), 0)
				into already_complete
				from ready_goods rg
				where rg.owner_id = new.owner_id and rg.id != new.id and rg.status_id in (1002, 3000) and rg.goods_id = new.goods_id;
		
			new.amount = new.amount - already_complete;
			
			need_calc = true;
		end if;

		if (coalesce(new.cost, 0::money) = 0::money or need_calc) then
			new.cost = new.amount * new.price;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_ready_goods() OWNER TO postgres;
