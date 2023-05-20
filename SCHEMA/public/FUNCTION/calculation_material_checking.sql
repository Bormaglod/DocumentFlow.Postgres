CREATE OR REPLACE FUNCTION public.calculation_material_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	calc_state calculation_state;
begin
	if (new.deleted) then
		return new;
	end if;

	select state into calc_state from calculation where id = new.owner_id;
	if (calc_state = 'expired'::calculation_state) then
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Калькуляция находится в архиве. Менять её нельзя.');
	end if;

	if (new.item_id is null) then
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Необходимо выбрать материал.');
	end if;

	if (calc_state = 'approved'::calculation_state and not new.is_giving) then
		new.amount = coalesce(new.amount, 0);
		if (new.amount = 0) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Укажите количество материала.');
		end if;

		new.price = coalesce(new.price, 0);
		/*if (new.price = 0) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Укажите цену материала.');
		end if;*/
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_material_checking() OWNER TO postgres;
