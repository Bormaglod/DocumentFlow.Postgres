CREATE OR REPLACE FUNCTION public.debt_adjustment_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	contract_debt_id uuid;
	contract_credit_id uuid;
begin
	if (new.carried_out) then
		if (new.contractor_id is null) then
			raise 'Необходимо выбрать контрагента';
		end if;
	
		if (new.document_debt_id is null) then
			raise 'Необходимо выбрать документ (долг контрагента)';
		end if;
	
		if (new.document_credit_id is null) then
			raise 'Необходимо выбрать документ (долг контрагента)';
		end if;
	
		if (coalesce(new.transaction_amount, 0) <= 0) then
			raise 'Сумма корректировки должна быть больше 0';
		end if;
	
		select contract_id into contract_debt_id from waybill_receipt where id = new.document_debt_id;
		select contract_id into contract_credit_id from waybill_receipt where id = new.document_credit_id;
	
		if (contract_debt_id != contract_credit_id) then
			call contractor_debt_reduce(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, new.contractor_id, contract_debt_id, new.transaction_amount);
			call contractor_debt_increase(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, new.contractor_id, contract_credit_id, new.transaction_amount);
		end if;
	else
		delete from balance_contractor where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.debt_adjustment_accept() OWNER TO postgres;
