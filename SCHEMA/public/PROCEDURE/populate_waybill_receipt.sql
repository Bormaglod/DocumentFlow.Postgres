CREATE OR REPLACE PROCEDURE public.populate_waybill_receipt(waybill_receipt_id uuid, purchase_request_id uuid = NULL::uuid)
    LANGUAGE plpgsql
    AS $$
begin
	delete from waybill_receipt_price where owner_id = waybill_receipt_id;

	if (purchase_request_id is not null) then
		insert into waybill_receipt_price (owner_id, reference_id, amount, price, product_cost, tax, tax_value, full_cost)
			select 
				waybill_receipt_id, prp.reference_id, prp.amount, prp.price, prp.product_cost, prp.tax, prp.tax_value, prp.full_cost 
			from purchase_request_price prp 
			where prp.owner_id = purchase_request_id;
	end if;
end;
$$;

ALTER PROCEDURE public.populate_waybill_receipt(waybill_receipt_id uuid, purchase_request_id uuid) OWNER TO postgres;
