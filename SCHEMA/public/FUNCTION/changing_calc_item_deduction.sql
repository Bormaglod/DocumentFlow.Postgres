CREATE OR REPLACE FUNCTION public.changing_calc_item_deduction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	status_value integer;
	deduction_base numeric;
	r_d record;
begin
	select status_id into status_value from calculation where id = new.owner_id;
	if (status_value not in (1000, 1004)) then
		raise 'Калькуляция должна быть в стостянии СОСТАВЛЕН или ИЗМЕНЯЕТСЯ';
	end if;

	if (new.status_id = 1001) then
		if (new.item_id is null) then
			raise 'Выберите базу для отчисления!';
		end if;
	
		select percentage, accrual_base into r_d from deduction where id = new.item_id;
		
		new.percentage = coalesce(new.percentage, 0);
		if (new.percentage = 0) then
			new.percentage = r_d.percentage;
		end if;
	
		if (r_d.accrual_base = 1) then
			select sum(cost) 
				into new.price
				from calc_item_goods
				where owner_id = new.owner_id and status_id = 1001;
		else
			select sum(cost) 
				into new.price
				from calc_item_operation
				where owner_id = new.owner_id and status_id = 1001; 
		end if;

		new.price = coalesce(new.price, 0);
		new.cost = new.price * new.percentage / 100;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_calc_item_deduction() OWNER TO postgres;
