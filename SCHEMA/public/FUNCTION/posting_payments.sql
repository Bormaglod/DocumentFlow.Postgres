CREATE OR REPLACE FUNCTION public.posting_payments(payment_order_id uuid = NULL::uuid) RETURNS TABLE(id uuid, owner_id uuid, user_created_id uuid, date_created timestamp with time zone, user_updated_id uuid, date_updated timestamp with time zone, deleted boolean, organization_id uuid, document_date timestamp with time zone, document_number integer, carried_out boolean, re_carried_out boolean, transaction_amount numeric, document_id uuid, discriminator character varying, document_name character varying, contractor_name character varying)
    LANGUAGE plpgsql
    AS $$
declare
	var_pp record;
begin
	for var_pp in
		select 
			pp.*,
			pp.tableoid::regclass::varchar as discriminator
		from posting_payments pp
			join organization o on (o.id = pp.organization_id)
		where (payment_order_id is null) or (pp.owner_id = payment_order_id)
	loop 
		id := var_pp.id;
		owner_id := var_pp.owner_id;
		user_created_id := var_pp.user_created_id;
		date_created := var_pp.date_created;
		user_updated_id := var_pp.user_updated_id;
		date_updated := var_pp.date_updated;
		deleted := var_pp.deleted;
		organization_id := var_pp.organization_id;
		document_date := var_pp.document_date;
		document_number := var_pp.document_number;
		carried_out := var_pp.carried_out;
		re_carried_out := var_pp.re_carried_out;
		transaction_amount := var_pp.transaction_amount;
		document_id := var_pp.document_id;
	
		if (var_pp.discriminator = 'posting_payments_purchase') then
			document_name := 'Заявка на расход';
			discriminator := 'purchase';
			select c.item_name
				into contractor_name
				from purchase_request pr
					left join contractor c on (c.id = pr.contractor_id)
				where pr.id = var_pp.document_id;
		elsif (var_pp.discriminator = 'posting_payments_receipt') then
			discriminator := 'receipt';
			document_name := 'Поступление';
			select c.item_name
				into contractor_name
				from waybill_receipt wr
					left join contractor c on (c.id = wr.contractor_id)
				where wr.id = var_pp.document_id;
		elsif (var_pp.discriminator = 'posting_payments_sale') then
			discriminator := 'sale';
			document_name := 'Реализация';
			select c.item_name
				into contractor_name
				from waybill_sale wr
					left join contractor c on (c.id = wr.contractor_id)
				where wr.id = var_pp.document_id;
		elseif (var_pp.discriminator = 'posting_payments_balance') then
			discriminator := 'balance';
			document_name := 'Нач. остаток';
			select c.item_name
				into contractor_name
				from initial_balance_contractor ibc 
					left join contractor c on (c.id = ibc.reference_id)
				where ibc.id = var_pp.document_id;
		end if;
	
		return next;
	end loop;
end;
$$;

ALTER FUNCTION public.posting_payments(payment_order_id uuid) OWNER TO postgres;
