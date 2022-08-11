CREATE OR REPLACE PROCEDURE public.calculate_employee_wages(gross_id uuid, b_year integer, b_month integer)
    LANGUAGE plpgsql
    AS $$
declare
	emp our_employee;
	item varchar;
	emp_wage numeric;
	w1c numeric;
	iid uuid;
begin
	delete from gross_payroll_employee where owner_id = gross_id;

	for emp in
		select * from our_employee
	loop
		foreach item in array emp.income_items
		loop
			select id into iid from income_item where code = item limit 1;
			
			if (item in ('ЗПЛ1С', 'СДЛ_1С')) then
				select 
					sum(wce.wage) 
				into emp_wage
				from wage1c wc 
					join wage1c_employee wce on wce.owner_id = wc.id
				where 
					employee_id = emp.id and 
					billing_year = b_year and 
					billing_month = b_month and
					wc.carried_out
				group by wce.employee_id;
			
				emp_wage = coalesce(emp_wage, 0);
				w1c := emp_wage;
			end if;
		
			if (item in ('СДЛ', 'СДЛ_1С')) then
				select 
					sum(salary) 
				into emp_wage
				from operations_performed 
				where 
					employee_id = emp.id and 
					extract(year from document_date) = b_year and 
					extract(month from document_date) = b_month and
					carried_out;
				
				emp_wage = coalesce(emp_wage, 0);
				w1c := emp_wage - w1c;
			end if;
		
			if (item = 'СДЛ_1С') then
				emp_wage := w1c;
			end if;
		
			if (emp_wage != 0) then
				insert into gross_payroll_employee (owner_id, employee_id, income_item_id, wage) values (gross_id, emp.id, iid, emp_wage);
			end if;
		end loop;
	end loop;
end;
$$;

ALTER PROCEDURE public.calculate_employee_wages(gross_id uuid, b_year integer, b_month integer) OWNER TO postgres;
