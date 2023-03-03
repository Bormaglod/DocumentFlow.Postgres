CREATE OR REPLACE FUNCTION public.calculation_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	goods_cnt integer;
	cnt integer;
begin
	if (new.state = 'approved'::calculation_state) then
		new.cost_price = coalesce(new.cost_price, 0);
		if (new.cost_price = 0) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Не определена себестоимость изделия.');
		end if;
	
		new.profit_percent = coalesce(new.profit_percent, 0);
		if (new.profit_percent = 0) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Не определена рентабельность изделия.');
		end if;
	
		new.profit_value = coalesce(new.profit_value, 0);
		if (new.profit_value = 0) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Не определена прибыль изделия.');
		end if;
	
		new.price = coalesce(new.price, 0);
		if (new.price = 0) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Укажите цену изделия.');
		end if;
	end if;

	raise notice 'CALCULATION CHECKING';
	if (new.state = old.state) then
		if (new.state = 'expired'::calculation_state) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Калькуляция находится в архиве. Менять её нельзя.');
		end if;
	end if;

	if (new.state != old.state) then
		raise notice 'CALCULATION CHECKING: state changed.';
		if (new.state = 'approved'::calculation_state) then
			raise notice 'CALCULATION CHECKING: set state to approved.';
			if (exists(select 1 from calculation_material where owner_id = new.owner_id and (coalesce(amount, 0) = 0 or coalesce(price, 0) = 0))) then
				raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Выбраны материалы с неуказанным количеством или ценой.');
			end if;
		
			select 
				count(og.goods_id), count(c.owner_id)
			into
				goods_cnt, cnt
			from calculation_operation co  
				join operation_goods og on og.owner_id = co.item_id 
				left join calculation c on c.id = co.owner_id and c.owner_id = og.goods_id
			where co.owner_id = new.id;
		
			raise notice 'CALCULATION CHECKING: goods_cnt = %, cnt = %.', goods_cnt, cnt;
			if (goods_cnt > 0 and cnt = 0) then
				raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Выбрана операция, которую нельзя использовать для данного изделия.');
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_checking() OWNER TO postgres;
