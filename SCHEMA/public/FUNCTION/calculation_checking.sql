CREATE OR REPLACE FUNCTION public.calculation_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.state = 'approved'::calculation_state) then
		new.cost_price = coalesce(new.cost_price, 0);
		if (new.cost_price = 0) then
			raise 'Не определена себестоимость изделия';
		end if;
	
		new.profit_percent = coalesce(new.profit_percent, 0);
		if (new.profit_percent = 0) then
			raise 'Не определена рентабельность изделия';
		end if;
	
		new.profit_value = coalesce(new.profit_value, 0);
		if (new.profit_value = 0) then
			raise 'Не определена прибыль изделия';
		end if;
	
		new.price = coalesce(new.price, 0);
		if (new.price = 0) then
			raise 'Укажите цену изделия';
		end if;
	end if;

	if (new.state = 'expired'::calculation_state and new.state = old.state) then
		raise 'Калькуляция находится в архиве. Менять её нельзя.';
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_checking() OWNER TO postgres;
