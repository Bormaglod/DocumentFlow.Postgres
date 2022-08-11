CREATE OR REPLACE FUNCTION public.production_lot_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	pid uuid;
	p_sum numeric;
	p_all numeric;
begin
	if (new.carried_out) then
		select sum(quantity) 
			into p_sum 
			from production_lot 
			where owner_id = new.owner_id and carried_out and calculation_id = new.calculation_id
			group by owner_id, calculation_id;
		
		select sum(amount)
			into p_all
			from production_order_price
			where owner_id = new.owner_id and calculation_id = new.calculation_id;
		
		if (p_all < p_sum) then
			raise 'Общее количество изделий в партиях текущего заказа равно % шт., а в заказ содержит только % шт.', p_sum, p_all;
		end if;
	else
		for pid in
			select id from operations_performed where owner_id = new.id and carried_out
		loop 
			call execute_system_operation(pid, 'accept'::system_operation, false, 'operations_performed');
		end loop;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.production_lot_accept() OWNER TO postgres;
