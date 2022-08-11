CREATE OR REPLACE FUNCTION public.payment_order_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	distrib numeric;
	var_p record;
begin
	if (new.carried_out) then
		select sum(transaction_amount) into distrib from posting_payments where owner_id = new.id;
		if (new.transaction_amount < distrib) then
			raise 'Распределено больше денег, чем указано в платежном ордере';
		end if;
		
		if (new.transaction_amount > distrib) then
			raise 'Остались нераспределенные деньги.';
		end if;
	else 
		delete from balance_contractor where owner_id = new.id;
	end if;

	for var_p in
		select id, tableoid::regclass::varchar as table_name from posting_payments where owner_id = new.id
	loop
		call execute_system_operation(var_p.id, 'accept'::system_operation, new.carried_out, var_p.table_name);
	end loop;

	call send_notify('posting_payments', new.id);

	return new;
end;
$$;

ALTER FUNCTION public.payment_order_accept() OWNER TO postgres;
