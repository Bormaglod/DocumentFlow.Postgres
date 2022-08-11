CREATE OR REPLACE PROCEDURE public.make_prices_operations_relevant(calc_id uuid)
    LANGUAGE plpgsql
    AS $$
begin
	update calculation_operation
		set price = null
		where owner_id = calc_id;
	
	call send_notify('calculation_operation', calc_id);
	call send_notify('calculation_cutting', calc_id);
end;
$$;

ALTER PROCEDURE public.make_prices_operations_relevant(calc_id uuid) OWNER TO postgres;
