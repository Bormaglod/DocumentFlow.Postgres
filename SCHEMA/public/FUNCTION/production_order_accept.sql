CREATE OR REPLACE FUNCTION public.production_order_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	pid uuid;
begin
	if (not new.carried_out) then
		if (new.closed) then
			raise 'Заказ закрыт. Отмена проведения невозможна.';
		end if;
	
		for pid in
			select id from production_lot where owner_id = new.id and carried_out
		loop
			call execute_system_operation(pid, 'accept'::system_operation, false, 'production_lot');
		end loop;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.production_order_accept() OWNER TO postgres;
