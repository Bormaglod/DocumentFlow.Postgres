CREATE OR REPLACE PROCEDURE public.recalculate_deduction(calc_id uuid, base public.base_deduction)
    LANGUAGE plpgsql
    AS $$
declare
	new_cost numeric;
begin
	if (base = 'person'::base_deduction) then
		return;
	end if;

	if (base = 'salary'::base_deduction) then
		select sum(item_cost) into new_cost from calculation_operation where owner_id = calc_id and not deleted;
	else
		select sum(item_cost) into new_cost from calculation_material where owner_id = calc_id and not deleted;
	end if;

	update calculation_deduction 
		set price = new_cost,
			item_cost = new_cost * value / 100
		where owner_id = calc_id and item_id in (select id from deduction where base_calc = base) and not deleted;
end;
$$;

ALTER PROCEDURE public.recalculate_deduction(calc_id uuid, base public.base_deduction) OWNER TO postgres;

COMMENT ON PROCEDURE public.recalculate_deduction(calc_id uuid, base public.base_deduction) IS 'Пересчитывает значения удержаний с указанной базой начислений';
