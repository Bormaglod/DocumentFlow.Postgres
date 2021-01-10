CREATE OR REPLACE FUNCTION public.fill_invoice_detail(owner_code_id character varying, from_copy_id uuid, invoice_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	case owner_code_id
		when 'purchase_request' then
			delete from invoice_receipt_detail where owner_id = invoice_id;
			insert into invoice_receipt_detail (owner_id, goods_id, amount, price, cost, tax, tax_value, cost_with_tax) select invoice_id as owner_id, goods_id, amount, price, cost, tax, tax_value, cost_with_tax from purchase_request_detail where owner_id = from_copy_id;
		
		when 'production_order' then
			delete from invoice_sales_detail where owner_id = invoice_id;
			insert into invoice_sales_detail (owner_id, goods_id, amount, price, cost, tax, tax_value, cost_with_tax) select invoice_id as owner_id, goods_id, amount, price, cost, tax, tax_value, cost_with_tax from production_order_detail where owner_id = from_copy_id;

		else
			-- nothing
	end case;
end;
$$;

ALTER FUNCTION public.fill_invoice_detail(owner_code_id character varying, from_copy_id uuid, invoice_id uuid) OWNER TO postgres;
