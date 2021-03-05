CREATE OR REPLACE FUNCTION public.changing_operation_type() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	price_id uuid;
	price_prev numeric;
begin
	if (new.status_id = 1001) then
		new.hourly_salary = coalesce(new.hourly_salary, 0);
		if (new.hourly_salary <= 0) then
			raise 'Значение почасовой оплаты труда должно быть больше 0.';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_operation_type() OWNER TO postgres;
