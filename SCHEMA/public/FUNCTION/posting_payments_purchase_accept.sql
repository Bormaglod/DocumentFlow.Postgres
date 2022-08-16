CREATE OR REPLACE FUNCTION public.posting_payments_purchase_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	purchase_cost numeric;
	paid numeric;
	owner_accept bool;
begin
	if (new.carried_out) then
		-- общая сумма для списания по документу
		select sum(full_cost) into purchase_cost from purchase_request_price where owner_id = new.document_id;

		-- сумма уже распределённых денег по документу
		select sum(transaction_amount) into paid from posting_payments_purchase where document_id = new.document_id and carried_out;
		
		if (paid > purchase_cost) then
			raise 'Слишком большая сумма для распределения (превышение на %)', paid - purchase_cost;
		end if;
	end if;

	select carried_out into owner_accept from payment_order where id = new.owner_id;
	if (owner_accept) then
		update payment_order set re_carried_out = true where id = new.owner_id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.posting_payments_purchase_accept() OWNER TO postgres;
