CREATE OR REPLACE PROCEDURE public.set_calculation_item_cost(calc_id uuid)
    LANGUAGE plpgsql
    AS $$
declare
	new_cost numeric;
begin
	select sum(item_cost) into new_cost from calculation_item where owner_id = calc_id and not deleted;
	new_cost = coalesce(new_cost, 0);
	if (new_cost > 0) then
		update calculation 
			set cost_price = new_cost
			where id = calc_id;
		
		call send_notify('calculation', calc_id, 'refresh');
	end if;
end;
$$;

ALTER PROCEDURE public.set_calculation_item_cost(calc_id uuid) OWNER TO postgres;

COMMENT ON PROCEDURE public.set_calculation_item_cost(calc_id uuid) IS 'Расчитывает себестоимость калькуляции';
