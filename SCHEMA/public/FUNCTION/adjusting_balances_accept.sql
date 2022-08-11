CREATE OR REPLACE FUNCTION public.adjusting_balances_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	remainder numeric;
begin
	if (new.carried_out) then
		remainder = get_product_remainder(new.material_id, new.document_date);
		if (new.quantity < remainder) then
			call balance_material_expense(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, new.material_id, remainder - new.quantity);
		elsif (new.quantity > remainder) then
			call balance_material_receipt(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, new.material_id, new.quantity - remainder);
		end if;
	else 
		delete from balance_material where owner_id = new.id;
	end if;

	-- все проведенные документы, которые изменяют остаток материалов и меняют среднюю цену материала
	-- отметим для перепроведения

	-- отмечаются все документы с корректировкой остатка этого-же материала
	update adjusting_balances 
		set re_carried_out = true
		where document_date > new.document_date and material_id = new.material_id and carried_out;
	
	-- отмечаются все реализации материала
	with t as
	(
		select distinct ws.id
		from waybill_sale ws
			join waybill_sale_price_material wspm on wspm.owner_id = ws.id
		where 
			ws.document_date > new.document_date and
			ws.carried_out and
			wspm.reference_id = new.material_id
	)
	update waybill_sale ws
		set re_carried_out = true
		from t
		where ws.id = t.id;
	
	return new;
end;
$$;

ALTER FUNCTION public.adjusting_balances_accept() OWNER TO postgres;
