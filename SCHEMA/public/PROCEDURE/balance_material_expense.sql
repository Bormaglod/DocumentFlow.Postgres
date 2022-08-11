CREATE OR REPLACE PROCEDURE public.balance_material_expense(document_id uuid, doc_code character varying, doc_number integer, expense_date timestamp with time zone, material_id uuid, quantity numeric)
    LANGUAGE plpgsql
    AS $$
declare 
	price_info price_data;
begin
	price_info.id = material_id;
	price_info.table_name = 'material';
	price_info.amount = quantity;

	call balance_product_expense(document_id, doc_code, doc_number, expense_date, price_info);
end;
$$;

ALTER PROCEDURE public.balance_material_expense(document_id uuid, doc_code character varying, doc_number integer, expense_date timestamp with time zone, material_id uuid, quantity numeric) OWNER TO postgres;
