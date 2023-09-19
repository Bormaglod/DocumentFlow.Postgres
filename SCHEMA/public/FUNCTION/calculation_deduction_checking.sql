CREATE OR REPLACE FUNCTION public.calculation_deduction_checking() RETURNS trigger
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
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Необходимо выбрать статью удержания');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_deduction_checking() OWNER TO postgres;
