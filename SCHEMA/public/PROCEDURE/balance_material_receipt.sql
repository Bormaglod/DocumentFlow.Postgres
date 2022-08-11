CREATE OR REPLACE PROCEDURE public.balance_material_receipt(document_id uuid, doc_code character varying, doc_number integer, receipt_date timestamp with time zone, material_id uuid, quantity numeric, material_cost numeric = NULL::numeric)
    LANGUAGE plpgsql
    AS $$
declare 
	price_info price_data;
begin
	price_info.id = material_id;
	price_info.table_name = 'material';
	price_info.amount = quantity;

	if (material_cost is null) then
		price_info.product_cost = quantity * average_price(material_id, receipt_date);
	else
		price_info.product_cost = material_cost;
	end if;

	call balance_product_receipt(document_id, doc_code, doc_number, receipt_date, price_info);
end;
$$;

ALTER PROCEDURE public.balance_material_receipt(document_id uuid, doc_code character varying, doc_number integer, receipt_date timestamp with time zone, material_id uuid, quantity numeric, material_cost numeric) OWNER TO postgres;
