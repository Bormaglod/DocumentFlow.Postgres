CREATE OR REPLACE PROCEDURE public.lot_to_waybill(prod_lot_id uuid, waybill_id uuid, goods_quantity numeric)
    LANGUAGE plpgsql
    AS $$
declare 
	goods_id uuid;
	full_quantity numeric;
	complete_quantity numeric;
	waybill_rec record;
	p_cost numeric;
	p_tax numeric;
	p_full_cost numeric;
	remaind numeric;
begin
	-- изделие и количество в партии
	select 
		c.owner_id as goods_id,
		pl.quantity
	into goods_id, full_quantity
	from production_lot pl
		join calculation c on c.id = pl.calculation_id
	where pl.id = prod_lot_id;

	-- оприходованные изделий в партиях
	select sum(quantity) into complete_quantity from lot_sale where lot_id = prod_lot_id;

	-- остаток неоприходованных изделий в партии
	remaind := full_quantity - coalesce(complete_quantity, 0);

	-- найдем любую одну запись в накладной с изделием из партии и не связанной ни с одной партией
	select 
		id,
		amount,
		price,
		product_cost,
		tax,
		tax_value,
		full_cost
	into waybill_rec 
	from waybill_sale_price_goods 
	where owner_id = waybill_id and reference_id = goods_id and lot_id is null
	limit 1;

	if (waybill_rec.id is null) then
		raise exception 'Не найдено ни одной подходящей записи с указанным изделием.';
	end if;

	if (goods_quantity is null) then
		goods_quantity := waybill_rec.amount;
	end if;

	-- если запись в накладной содержит большее количество изделий, чем остаток в партии, то эту заптсь откорректируем с учетом
	-- количества изделий в партии, а разницу запишем в новую запись
	if (goods_quantity > remaind) then
		-- новые значения для remaind изделий
		p_cost := remaind * waybill_rec.price;
		p_tax := p_cost * waybill_rec.tax / 100.0;
		p_full_cost := p_cost + p_tax;
	
		update waybill_sale_price_goods 
			set lot_id = prod_lot_id,
				amount = remaind,
				product_cost = p_cost,
				tax_value = p_tax,
				full_cost = p_full_cost
			where id = waybill_rec.id;
		
		-- остаток запишем в новую запись
		waybill_rec.amount := goods_quantity - remaind;
		waybill_rec.product_cost := waybill_rec.product_cost - p_cost;
		waybill_rec.tax_value := waybill_rec.tax_value - p_tax;
		waybill_rec.full_cost := waybill_rec.full_cost - p_full_cost;
		
		insert into waybill_sale_price_goods (owner_id, reference_id, amount, price, product_cost, tax, tax_value, full_cost)
			values (waybill_id, goods_id, waybill_rec.amount, waybill_rec.price, waybill_rec.product_cost, waybill_rec.tax, waybill_rec.tax_value, waybill_rec.full_cost);
		
		insert into lot_sale (waybill_sale_id, lot_id, quantity) values (waybill_id, prod_lot_id, remaind);
	
		raise notice 'Списывается товара в количестве: %', remaind;
		raise notice 'Остаток в накладной: %', waybill_rec.amount;
	else
		update waybill_sale_price_goods 
			set lot_id = prod_lot_id
			where id = waybill_rec.id;
		
		insert into lot_sale (waybill_sale_id, lot_id, quantity) values (waybill_id, prod_lot_id, goods_quantity);
	
		raise notice 'Списывается товара в количестве: %', goods_quantity;
		raise notice 'Остаток в партии: %', remaind - goods_quantity;
	end if;
end;
$$;

ALTER PROCEDURE public.lot_to_waybill(prod_lot_id uuid, waybill_id uuid, goods_quantity numeric) OWNER TO postgres;

COMMENT ON PROCEDURE public.lot_to_waybill(prod_lot_id uuid, waybill_id uuid, goods_quantity numeric) IS 'Процедура предназначена для добавления изделий из партии указанной в параметре prod_lot_id в документ реализации указанный в параметре waybill_id в количестве goods_quantity. Если количество не указано (равно NULL), то оно расчитывается.';
