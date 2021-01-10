CREATE OR REPLACE FUNCTION public.get_required_operations(_order_id uuid, _goods_id uuid, _operation_id uuid, _using_goods_id uuid) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
	remaind integer;
begin
	with used as
	(
		select po.using_goods_id, sum(po.amount) as amount
			from perform_operation po
			where 
				po.order_id = _order_id and
				po.goods_id = _goods_id and
				po.operation_id = _operation_id and
				po.using_goods_id = _using_goods_id and
				po.status_id = 3101
			group by
				po.using_goods_id
	)		
	select 
		(pod.amount * (um.count_by_goods / um.count_by_operation) - coalesce(u.amount, 0))::integer
		into remaind
		from production_order po
			join production_order_detail pod on (pod.owner_id = po.id)
			join calculation c on (c.id = pod.calculation_id)
			join calc_item_operation cio on (cio.owner_id = c.id)
			join used_material um on (um.calc_item_operation_id = cio.id)
			left join used u on (u.using_goods_id = um.goods_id)
		where 
			po.id = _order_id and
			pod.goods_id = _goods_id and
			cio.item_id = _operation_id and
			um.goods_id = _using_goods_id;
		
	return coalesce(remaind, 0);
end;
$$;

ALTER FUNCTION public.get_required_operations(_order_id uuid, _goods_id uuid, _operation_id uuid, _using_goods_id uuid) OWNER TO postgres;
