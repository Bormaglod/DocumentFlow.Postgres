CREATE OR REPLACE FUNCTION public.changing_calculation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	-- => КОРРЕКТЕН
	if (new.status_id = 1001) then
		select sum(cost) into new.cost from calc_item where owner_id = new.id and status_id = 1001;
	
		if (new.profit_percent > 0 or new.profit_value > 0::money) then
			if (new.profit_percent > 0) then
				new.profit_value = new.cost * new.profit_percent / 100;
			else
				new.profit_percent = new.profit_value / new.cost * 100;
			end if;

			new.price = new.cost + new.profit_value;
		else
			if (new.price > 0::money) then
				new.profit_value = new.price - new.cost;
				new.profit_percent = new.profit_value / new.cost * 100;
			else
				new.price = new.cost;
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_calculation() OWNER TO postgres;
