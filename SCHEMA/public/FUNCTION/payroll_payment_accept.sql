CREATE OR REPLACE FUNCTION public.payroll_payment_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	payroll_accept boolean;
	emp record;
begin
	if (new.carried_out) then
		select carried_out into payroll_accept from payroll where id = new.owner_id;
		if (not payroll_accept) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Платёжная ведомость не проведена. Выплата невозможна.');
		end if;
	
		for emp in
			select employee_id, wage from payroll_employee where owner_id = new.owner_id
		loop
			call employee_debt_change(new.id, TG_TABLE_NAME::varchar, new.document_number, new.document_date, emp.employee_id, emp.wage, 1);
		end loop;
	else
		delete from balance_employee where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.payroll_payment_accept() OWNER TO postgres;
