CREATE OR REPLACE FUNCTION public.product_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	calc_state calculation_state;
begin
	if (not new.is_folder) then
		if (TG_TABLE_NAME::varchar = 'goods') then
			if (new.calculation_id is not null and (old.calculation_id is null or new.calculation_id != old.calculation_id)) then
				select state into calc_state from calculation where id = new.calculation_id;
				
				if (calc_state = 'expired'::calculation_state) then
					raise 'Калькуляция утратила силу и не может быть выбрана';
				end if;

				if (calc_state = 'prepare'::calculation_state) then
					raise 'Калькуляция находится в состоянии подготовки и не может быть выбрана';
				end if;
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.product_checking() OWNER TO postgres;
