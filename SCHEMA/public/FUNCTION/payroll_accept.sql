CREATE OR REPLACE FUNCTION public.payroll_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	gross_accept boolean;
	payment_id uuid;
begin
	if (new.carried_out) then
		select carried_out into gross_accept from gross_payroll where id = new.owner_id;
		if (not gross_accept) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Начисление заработной платы не проведено.');
		end if;
	else
		for payment_id in
			select id from payroll_payment where owner_id = new.id and carried_out 
		loop 
			call execute_system_operation(payment_id, 'accept'::system_operation, false, 'payroll_payment');
		end loop;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.payroll_accept() OWNER TO postgres;
