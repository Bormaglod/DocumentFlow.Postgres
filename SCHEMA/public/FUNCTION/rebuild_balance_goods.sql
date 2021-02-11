CREATE OR REPLACE FUNCTION public.rebuild_balance_goods(rel_goods_id uuid, relevance_date timestamp with time zone) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	r record;
	avg_price average_price;
	inventory_amount numeric;
begin
	-- все расходные остатки по указанному материалу добавленные после даты relevance_date (а также все записи об инвентаризации)
	-- доход считать не будем, там ничего не пересчитывается
	for r in
		select id, amount, document_date, status_id, owner_id
			from only balance_goods 
			where 
				reference_id = rel_goods_id and
				document_date > relevance_date and 
				(
					(amount < 0::money and status_id in (1110, 1111)) or
					(status_id = 1112)
				)
			order by document_date
	loop
		avg_price = get_average_price(rel_goods_id, r.document_date, r.amount);
		if (avg_price.avg_price = 0::money) then
			avg_price.avg_price = get_price('goods', rel_goods_id, r.document_date);
			avg_price.price = avg_price.avg_price * r.amount;
		end if;
	
		if (r.status_id = 1112) then
			select amount into inventory_amount from inventory_detail where owner_id = r.owner_id and goods_id = rel_goods_id;
			
			inventory_amount = inventory_amount - avg_price.amount;
			update balance_goods set operation_summa = inventory_amount * avg_price.avg_price, amount = inventory_amount where id = r.id;
		else
			update balance_goods set operation_summa = avg_price.price where id = r.id;
		end if;
	end loop;

	perform send_notify_list('balance_goods', rel_goods_id, 'refresh');
end;
$$;

ALTER FUNCTION public.rebuild_balance_goods(rel_goods_id uuid, relevance_date timestamp with time zone) OWNER TO postgres;

COMMENT ON FUNCTION public.rebuild_balance_goods(rel_goods_id uuid, relevance_date timestamp with time zone) IS 'Пересчитывает сумму остатка материалов
- rel_goods_id - идентификатор материала, по которому было внесено изменение в таблицу остатков
- relevance_date - дата изменения, после которой надо сделать пересчет';
