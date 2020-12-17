CREATE OR REPLACE FUNCTION public.fill_production_operations(order_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	rec record;
	op_id uuid;
begin
	for rec in
		select pod.goods_id, cio.item_id as operation_id, pod.amount * cio.amount as amount
			from production_order_detail pod 
				join calc_item_operation cio on (cio.owner_id = pod.calculation_id)
			where pod.owner_id = order_id
	loop
		insert into production_operation (owner_id, goods_id, operation_id, amount) values (order_id, rec.goods_id, rec.operation_id, rec.amount) returning id into op_id;
		update production_operation set status_id = 1001 where id = op_id;
	end loop;
end;
$$;

ALTER FUNCTION public.fill_production_operations(order_id uuid) OWNER TO postgres;
