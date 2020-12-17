CREATE OR REPLACE FUNCTION public.changed_deduction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if (new.status_id = 1001) then
    	new.accrual_base = coalesce(new.accrual_base, 0);
		if (new.accrual_base = 0) then
			raise 'Необходимо выбрать базу для начисления';
		end if;
	
		new.percentage = coalesce(new.percentage, 0);
		if (new.percentage <= 0) then
			raise 'Необходимо указать процент отчиления от указанной базы.';
		end if;
	end if;
	return new;
end;
$$;

ALTER FUNCTION public.changed_deduction() OWNER TO postgres;
