CREATE OR REPLACE FUNCTION public.payment_order_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	distrib numeric;
	var_p record;
	cid uuid;
	pp record;
	document_table varchar;
begin
	if (new.carried_out) then
		select sum(transaction_amount) into distrib from posting_payments where owner_id = new.id and carried_out;
	
		if (distrib is null) then
			raise 'Нет сумм к распределению.';
		end if;
	
		if (new.transaction_amount < distrib) then
			raise 'Распределено больше денег, чем указано в платежном ордере';
		end if;
		
		if (new.transaction_amount > distrib) then
			raise 'Остались нераспределенные деньги.';
		end if;
	
		for pp in
			select 
				document_id, 
				sum(transaction_amount) as transaction_amount, 
				tableoid::regclass::varchar as table_name 
			from posting_payments 
			where owner_id = new.id and carried_out 
			group by tableoid, document_id 
		loop
			if (pp.table_name = 'posting_payments_receipt') then
				select contract_id into cid from waybill_receipt where id = pp.document_id;
			elsif (pp.table_name = 'posting_payments_purchase') then
				select contract_id into cid from purchase_request where id = pp.document_id;
			elseif (pp.table_name = 'posting_payments_sale') then
				select contract_id into cid from waybill_sale where id = pp.document_id;
			else
				raise 'payment_order_accept(). Для таблицы % нет соответствия с таблицей документов.', pp.table_name; 
			end if;
		
			if (new.direction = 'expense'::payment_direction) then
				-- уменьшим наш долг перед контрагентом (увеличив его долг перед нами) по каждому договору в отдельности
				call contractor_debt_increase(new.id, 'payment_order', new.document_number, new.document_date, new.contractor_id, cid, pp.transaction_amount);
			else
				-- увеличим наш долг перед контрагентом (уменьшив его долг перед нами)
				call contractor_debt_reduce(new.id, 'payment_order', new.document_number, new.document_date, new.contractor_id, cid, pp.transaction_amount);
			end if;
		end loop;
	else 
		for var_p in
			select id, tableoid::regclass::varchar as table_name from posting_payments where owner_id = new.id and not carried_out
		loop
			call execute_system_operation(var_p.id, 'accept'::system_operation, new.carried_out, var_p.table_name);
		end loop;

		delete from balance_contractor where owner_id = new.id;
	end if;

	call send_notify('posting_payments', new.id);

	return new;
end;
$$;

ALTER FUNCTION public.payment_order_accept() OWNER TO postgres;
