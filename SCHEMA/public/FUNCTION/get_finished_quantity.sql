CREATE OR REPLACE FUNCTION public.get_finished_quantity(lot_id uuid) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
declare
	executed numeric;
	finished numeric;
begin
	select 
		coalesce(sum(op.quantity) / co.repeats, 0)
	into
		executed
	from operations_performed op 
		join calculation_operation co on co.id = op.operation_id
	where op.owner_id = lot_id 
	group by co.id 
	order by 1
	limit 1;

	select 
		coalesce(sum(quantity), 0)
	into
		finished
	from finished_goods
	where owner_id = lot_id;

	return coalesce(executed, 0) - finished;
end;
$$;

ALTER FUNCTION public.get_finished_quantity(lot_id uuid) OWNER TO postgres;
