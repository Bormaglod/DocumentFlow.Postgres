CREATE OR REPLACE FUNCTION public.fill_invoice_details(invoice_id uuid, purchase_id uuid) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	delete from invoice_receipt_detail where owner_id = invoice_id;
	insert into invoice_receipt_detail (owner_id, goods_id, amount, price, cost, tax, tax_value, cost_with_tax) select invoice_id as owner_id, goods_id, amount, price, cost, tax, tax_value, cost_with_tax from purchase_request_detail where owner_id = purchase_id;
end;
$$;

ALTER FUNCTION public.fill_invoice_details(invoice_id uuid, purchase_id uuid) OWNER TO postgres;
