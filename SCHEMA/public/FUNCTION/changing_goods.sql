CREATE OR REPLACE FUNCTION public.changing_goods() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	goods_price numeric;
	goods_weight decimal;
begin
	if (new.status_id = 1001) then
		if (new.tax is null) then
			raise 'Укажите значение ставки НДС';
		end if;
	
		new.measurement_id = coalesce(new.measurement_id, '9f463a28-b416-4176-bf20-70cbd31786af'::uuid); -- штука
		new.min_order = coalesce(new.min_order, 0);
		new.is_service = coalesce(new.is_service, false);
	
		select price into goods_price from calculation where owner_id = new.id and status_id = 1002;
		if (goods_price is null) then
			new.price = coalesce(new.price, 0);
			if (new.price = 0) then
				raise 'Должна быть установлена цена изделия.';
			end if;
		else
			new.price = goods_price;
		end if;
	
		if (new.is_service) then
			new.weight = 0;
		else
			select sum(cig.amount * g.weight)
				into goods_weight
				from calc_item_goods cig 
					join calculation c ON (c.id = cig.owner_id and c.status_id = 1002)
					join goods g on (g.id = cig.item_id)
				where 
					c.owner_id = new.id;
			if (goods_weight is not null) then
				new.weight = goods_weight;
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_goods() OWNER TO postgres;
