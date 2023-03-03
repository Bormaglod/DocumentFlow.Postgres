CREATE OR REPLACE FUNCTION public.calculation_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	-- при вставке состояние калькуляции должно быть prepare всегда
	if (TG_OP = 'INSERT') then 
		new.state = 'prepare'::calculation_state;
	end if;

	new.cost_price = coalesce(new.cost_price, 0);
	if (new.cost_price = 0) then
		select sum(item_cost) into new.cost_price from calculation_item where owner_id = new.id and not deleted;
	end if;

	if (new.profit_percent > 0 or new.profit_value > 0) then
		if (new.profit_percent > 0) then
			new.profit_value := new.cost_price * new.profit_percent / 100;
		else
			new.profit_percent := new.profit_value / new.cost_price * 100;
		end if;

		new.price := new.cost_price + new.profit_value;
	else
		if (new.price > 0) then
			new.profit_value := new.price - new.cost_price;
			new.profit_percent := new.profit_value / new.cost_price * 100;
		else
			new.price := new.cost_price;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_changing() OWNER TO postgres;
