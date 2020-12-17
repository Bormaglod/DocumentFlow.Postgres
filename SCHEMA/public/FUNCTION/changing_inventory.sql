CREATE OR REPLACE FUNCTION public.changing_inventory() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	count_rows integer;
begin
	-- => КОРРЕКТЕН
	if (new.status_id = 1001) then 
		if (new.employee_id is null) then
			raise 'Необходимо указать сотрудника!';
		end if;
	
		select count(*) into count_rows from inventory_detail where owner_id = new.id;
		if (count_rows = 0) then
			raise 'Заполните табличную часть!';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_inventory() OWNER TO postgres;
