CREATE OR REPLACE FUNCTION public.get_list_payments(payment_document_id uuid) RETURNS TABLE(id uuid, owner_id uuid, user_created_id uuid, date_created timestamp with time zone, user_updated_id uuid, date_updated timestamp with time zone, deleted boolean, organization_id uuid, document_date timestamp with time zone, document_number integer, carried_out boolean, re_carried_out boolean, contractor_id uuid, date_operation date, transaction_amount numeric, direction public.payment_direction, payment_number character varying, posting_transaction numeric, document_id uuid)
    LANGUAGE plpgsql
    AS $$
declare
	var_r record;
begin
	for var_r in
		with recursive rpo (id, owner_id, user_created_id, date_created, user_updated_id, date_updated, deleted, organization_id, document_date, document_number, carried_out, re_carried_out, contractor_id, date_operation, transaction_amount, direction, payment_number, posting_transaction, document_id, document_owner_id) as
		(
			select
				payment_order.*, 
				pp.transaction_amount as posting_transaction, 
				pp.document_id,
				wr.owner_id as document_owner_id
			from payment_order
				join posting_payments as pp on pp.owner_id = payment_order.id
				left join waybill_receipt wr on wr.id = pp.document_id
			where 
				pp.document_id = payment_document_id and 
				pp.carried_out
		
			union all
	
			select
				po.*, 
				pp.transaction_amount as posting_transaction, 
				pp.document_id,
				null as document_owner_id
			from payment_order po
				join posting_payments as pp on pp.owner_id = po.id
				join rpo on rpo.document_owner_id = pp.document_id
			where 
				pp.carried_out
		)
		select * from rpo where rpo.carried_out
	loop
		id := var_r.id;
		owner_id := var_r.owner_id;
		user_created_id := var_r.user_created_id;
		date_created := var_r.date_created;
		user_updated_id := var_r.user_updated_id;
		date_updated := var_r.date_updated;
		deleted := var_r.deleted;
		organization_id := var_r.organization_id;
		document_date := var_r.document_date;
		document_number := var_r.document_number;
		carried_out := var_r.carried_out;
		re_carried_out := var_r.re_carried_out;
		contractor_id := var_r.contractor_id;
		date_operation := var_r.date_operation;
		transaction_amount := var_r.transaction_amount;
		direction := var_r.direction;
		payment_number := var_r.payment_number;
		posting_transaction := var_r.posting_transaction;
		document_id := var_r.document_id;
		return next;
	end loop;
end;
$$;

ALTER FUNCTION public.get_list_payments(payment_document_id uuid) OWNER TO postgres;

COMMENT ON FUNCTION public.get_list_payments(payment_document_id uuid) IS 'Возвращает список платежных документов по указанному документу. Это может быть заявка на расход или поступление материалов. Заявка состоит из предоплат, соответственно все эти платежи будут включены в список платежей при поступлении материала (если в поступлении указана соответствующая заявка).';
