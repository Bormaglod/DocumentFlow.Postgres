CREATE OR REPLACE FUNCTION public.posting_payments_receipt_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	waybill_cost numeric;
	paid numeric;
	po payment_order;
	cid uuid;
begin
	if (new.carried_out) then
		select sum(full_cost) into waybill_cost from waybill_receipt_price where owner_id = new.document_id;
		select sum(transaction_amount) into paid from posting_payments_receipt where document_id = new.document_id and carried_out;
		
		if (paid > waybill_cost) then
			raise 'Слишком большая сумма для распределения (превышение на %)', paid - waybill_cost;
		end if;
	
		select contract_id into cid from waybill_receipt where id = new.document_id;
	
		select * from payment_order into po where id = new.owner_id;
		call contractor_debt_increase(po.id, 'payment_order', po.document_number, po.document_date, po.contractor_id, cid, new.transaction_amount);
	else
		-- уменьшение задолжености контрагента происходит в payment_order_accept()
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.posting_payments_receipt_accept() OWNER TO postgres;
