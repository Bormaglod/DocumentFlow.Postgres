CREATE OR REPLACE FUNCTION public.operation_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	k float4;
begin
	if (not new.is_folder) then
		new.manual_input := coalesce(new.manual_input, false);
		if (new.manual_input) then
			new.manual_input := false;
			return new;
		end if;

		-- Выработка за время [prod_time], шт.
		new.produced := coalesce(new.produced, 0);
	
		-- Время за которое было произведено [produced] операций, мин
		new.prod_time := coalesce(new.prod_time, 0);
	
		new.production_rate := 0;
		if (new.prod_time != 0) then
			-- Норма выработки, шт./час
			new.production_rate := new.produced * 3600 / new.prod_time;
		end if;

		if (new.production_rate != 0) then
			-- Плата за выполнение ед. операции
			select ot.salary / new.production_rate 
				into new.salary 
				from operation_type ot
				where ot.id = new.type_id;
		else
			new.salary := 0;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.operation_changing() OWNER TO postgres;
