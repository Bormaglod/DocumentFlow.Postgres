CREATE OR REPLACE FUNCTION public.gross_payroll_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	emps record;
	payroll_id uuid;
begin
	if (new.carried_out) then
		for emps in
			select employee_id, sum(wage) as wage from gross_payroll_employee where owner_id = new.id group by employee_id
		loop 
			call employee_debt_change(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, emps.employee_id, emps.wage, -1);
		end loop;
	else
		for payroll_id in
			select id from payroll where owner_id = new.id and carried_out 
		loop 
			call execute_system_operation(payroll_id, 'accept'::system_operation, false, 'payroll');
		end loop;
	
		delete from balance_employee where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.gross_payroll_accept() OWNER TO postgres;
