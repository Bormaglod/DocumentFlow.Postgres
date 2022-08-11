CREATE OR REPLACE FUNCTION public.initial_balance_contractor_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.carried_out) then
		if (new.amount < 0) then
			call contractor_debt_reduce(new.id, 'initial_balance_contractor', new.document_number, new.document_date, new.reference_id, new.contract_id, new.operation_summa);
		else
			call contractor_debt_increase(new.id, 'initial_balance_contractor', new.document_number, new.document_date, new.reference_id, new.contract_id, new.operation_summa);
		end if;
	else
		delete from balance_contractor where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.initial_balance_contractor_accept() OWNER TO postgres;
