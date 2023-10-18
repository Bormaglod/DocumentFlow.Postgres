CREATE OR REPLACE FUNCTION public.goods_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	calc_state calculation_state;
begin
	if (new.calculation_id is not null and (old.calculation_id is null or new.calculation_id != old.calculation_id)) then
		select state into calc_state from calculation where id = new.calculation_id;

		if (calc_state = 'expired'::calculation_state) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Калькуляция утратила силу и не может быть выбрана.');
		end if;

		if (calc_state = 'prepare'::calculation_state) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Калькуляция находится в состоянии подготовки и не может быть выбрана.');
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.goods_checking() OWNER TO postgres;
