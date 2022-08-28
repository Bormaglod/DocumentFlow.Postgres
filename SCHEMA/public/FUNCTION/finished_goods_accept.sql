CREATE OR REPLACE FUNCTION public.finished_goods_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	product_info price_data;
	finished_quantity numeric;
	lot_quantity numeric;
	state lot_state;
	prod_started bool;
begin
	if (new.carried_out) then
		product_info.id := new.goods_id;
		product_info.table_name := 'goods';
		product_info.amount := new.quantity;
		product_info.product_cost := new.product_cost;
	
		call balance_product_receipt(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, product_info);
	else 
		delete from balance_goods where owner_id = new.id;
	end if;

	select sum(quantity) into finished_quantity from finished_goods where owner_id = new.owner_id and carried_out;
	select quantity into lot_quantity from production_lot where id = new.owner_id;
	prod_started := exists(select 1 from operations_performed where owner_id = new.owner_id and carried_out);

	state = case 
		when not prod_started then 'created'::lot_state
		when finished_quantity < lot_quantity then 'production'::lot_state
		else 'completed'::lot_state
	end;

	call set_production_lot_state(new.owner_id, state);

	return new;
end;
$$;

ALTER FUNCTION public.finished_goods_accept() OWNER TO postgres;
