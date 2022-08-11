CREATE OR REPLACE FUNCTION public.operation_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (not new.is_folder) then
		if (new.type_id is null) then
			raise 'Необходимо указать тип операции';
		end if;
	
		-- Выработка за время [prod_time], шт.
		if (new.produced <= 0) then
			raise 'Выработка должна быть больше 0.';
		end if;

		-- Время за которое было произведено [produced] операций, мин
		if (new.prod_time <= 0) then
			raise 'Время выработки должно быть больше 0.';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.operation_checking() OWNER TO postgres;
