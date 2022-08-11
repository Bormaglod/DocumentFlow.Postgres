CREATE OR REPLACE FUNCTION public.finished_goods_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	product_info price_data;
begin
	if (new.carried_out) then
		product_info.id = new.goods_id;
		product_info.table_name = 'goods';
		product_info.amount = new.quantity;
		product_info.product_cost = new.product_cost;
	
		call balance_product_receipt(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, product_info);
	else 
		delete from balance_goods where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.finished_goods_accept() OWNER TO postgres;
