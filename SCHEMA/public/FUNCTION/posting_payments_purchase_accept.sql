CREATE OR REPLACE FUNCTION public.posting_payments_purchase_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	purchase_cost numeric;
	paid numeric;
	po payment_order;
	cid uuid;
begin
	if (new.carried_out) then
		select sum(full_cost) into purchase_cost from purchase_request_price where owner_id = new.document_id;
		select sum(transaction_amount) into paid from posting_payments_purchase where document_id = new.document_id and carried_out;
		
		if (paid > purchase_cost) then
			raise 'Слишком большая сумма для распределения (превышение на %)', paid - purchase_cost;
		end if;
	
		select contract_id into cid from purchase_request where id = new.document_id;
	
		select * from payment_order into po where id = new.owner_id;
		call contractor_debt_increase(po.id, 'payment_order', po.document_number, po.document_date, po.contractor_id, cid, new.transaction_amount);
	else
		-- уменьшение задолжености контрагента происходит в payment_order_accept()
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.posting_payments_purchase_accept() OWNER TO postgres;
