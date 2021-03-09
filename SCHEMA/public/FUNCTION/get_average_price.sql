CREATE OR REPLACE FUNCTION public.get_average_price(ref_goods_id uuid, relevance_date timestamp with time zone, goods_amount numeric = NULL::numeric) RETURNS SETOF public.average_price
    LANGUAGE plpgsql
    AS $$
declare
	p average_price;
	r record;
	avg_sum numeric;
begin
	select coalesce(sum(abs(operation_summa) * sign(amount)), 0) as operation_summa, coalesce(sum(amount), 0) as amount
    	into r
		from only balance_goods
		where
			reference_id = ref_goods_id and
			document_date < relevance_date and
			status_id in (1110, 1111, 1112);
		
	if (goods_amount is null) then
		p.amount = r.amount;
	else
		p.amount = goods_amount;
	end if;

	if (r.amount = 0) then
		p.avg_price = 0;
		p.price = 0;
	else
		avg_sum = r.operation_summa / r.amount;
		p.avg_price = round(avg_sum, 2);
		p.price = avg_sum * abs(p.amount);
	end if;

	return next p;
end;
$$;

ALTER FUNCTION public.get_average_price(ref_goods_id uuid, relevance_date timestamp with time zone, goods_amount numeric) OWNER TO postgres;

COMMENT ON FUNCTION public.get_average_price(ref_goods_id uuid, relevance_date timestamp with time zone, goods_amount numeric) IS 'Возвращает среднюю цену материала, стоимость материала исходя из его средней стоимости и его количество
- ref_goods_id - идентификатор материала
- relevance_date - дата от которой ведется поиск остатков
- goods_amount - количество материала для которого надо посчитать сумму (если null, то будет использоваться фактический остаток материала на указанную дату)';
