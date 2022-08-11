CREATE OR REPLACE FUNCTION public.calculation_operation_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	calc_state calculation_state;
	operation_amount integer;
begin
	if (new.deleted) then
		return new;
	end if;

	select state into calc_state from calculation where id = new.owner_id;
	if (calc_state = 'expired'::calculation_state) then
		raise 'Калькуляция находится в архиве. Менять её нельзя.';
	end if;

	if (new.item_id is null) then
		raise 'Необходимо выбрать базовую операцию';
	end if;

	if (new.material_id is null) then
		if (coalesce(new.material_amount) != 0) then
			raise 'Указано количество материала, но материал не выбран';
		end if;		
	else
		if (coalesce(new.material_amount, 0) = 0) then
			raise 'Укажите количество материала';
		end if;
	end if;
	
	if (coalesce(new.repeats, 0) <= 0) then
		raise 'Количество повторов операции должно быть больше 0!';
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_operation_checking() OWNER TO postgres;
