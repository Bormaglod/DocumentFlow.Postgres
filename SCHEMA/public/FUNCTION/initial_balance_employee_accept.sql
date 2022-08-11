CREATE OR REPLACE FUNCTION public.initial_balance_employee_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.carried_out) then
		call employee_debt_change(new.id, 'initial_balance_employee', new.document_number, new.document_date, new.reference_id, new.operation_summa, sign(new.amount)::integer);
	else
		delete from balance_employee where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.initial_balance_employee_accept() OWNER TO postgres;
