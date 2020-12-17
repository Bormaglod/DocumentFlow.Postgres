CREATE OR REPLACE FUNCTION public.changing_perform_operation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	-- => КОРРЕКТЕН
	-- ИСПРАВЛЯЕТСЯ => ВЫПОЛНЕНО
	if (new.status_id = 1001 or (old.status_id = 3102 and new.status_id = 3101)) then
		select new.amount * o.salary / coalesce(m.coefficient, 1)
			into new.salary 
			from operation o
				left join measurement m on (m.id = o.measurement_id)
			where o.id = new.operation_id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_perform_operation() OWNER TO postgres;
