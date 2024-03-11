CREATE OR REPLACE FUNCTION public.calculation_material_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.deleted) then
		return new;
	end if;

	new.amount := coalesce(new.amount, 0);
	if (new.price_method = 'is_giving'::price_setting_method) then
		new.price := 0;
		new.item_cost := 0;
	else
		new.price := coalesce(new.price, 0);
		
		if (new.price_method = 'average'::price_setting_method) then
			new.price := average_price(new.item_id, now());
			raise notice 'MATERIAL CHANGING: average_price = %', new.price;
			if (new.price is null) then
				select price into new.price from material where id = new.item_id;
			end if;
			raise notice 'MATERIAL CHANGING: finally price = %', new.price;
		elsif (new.price_method = 'dictionary'::price_setting_method) then
			select price into new.price from material where id = new.item_id;
		end if;
	
		new.item_cost = new.price * new.amount;
	end if;
	
	return new;
end;
$$;

ALTER FUNCTION public.calculation_material_changing() OWNER TO postgres;
