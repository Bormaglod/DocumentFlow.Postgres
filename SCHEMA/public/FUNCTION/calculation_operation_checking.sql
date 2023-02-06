CREATE OR REPLACE FUNCTION public.calculation_operation_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	calc_state calculation_state;
	operation_amount integer;
	gid uuid;
begin
	if (new.deleted) then
		return new;
	end if;

	select state into calc_state from calculation where id = new.owner_id;
	if (calc_state = 'expired'::calculation_state) then
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Калькуляция находится в архиве. Менять её нельзя.');
	end if;

	if (new.item_id is null) then
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Необходимо выбрать базовую операцию');
	end if;

	if (new.material_id is null) then
		if (coalesce(new.material_amount) != 0) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Указано количество материала, но материал не выбран');
		end if;		
	else
		if (coalesce(new.material_amount, 0) = 0) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Укажите количество материала');
		end if;
	end if;
	
	if (coalesce(new.repeats, 0) <= 0) then
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Количество повторов операции должно быть больше 0!');
	end if;

	select owner_id into gid from calculation where id = new.owner_id;

	-- если существует хотя-бы одна запись с выбранной операцией
	if (exists(select 1 from operation_goods where owner_id = new.item_id)) then
		-- то должна быть запись и с указанным изделием, т.е. операция допустима
		-- только для выбранных изделий
		if (not exists(select 1 from operation_goods where owner_id = new.item_id and goods_id = gid)) then 
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Выбранную операцию использовать для данного изделия нельзя.');
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_operation_checking() OWNER TO postgres;
