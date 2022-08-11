CREATE OR REPLACE PROCEDURE public.make_prices_materials_relevant(calc_id uuid)
    LANGUAGE plpgsql
    AS $$
begin
	call lock_document(calc_id);
	
	update calculation_material
		set price = null
		where owner_id = calc_id;
	
	call recalculate_deduction(calc_id, 'material'::base_deduction);
	call unlock_document(calc_id);

	call set_calculation_item_cost(calc_id);

	call send_notify('calculation_material', calc_id);
	call send_notify('calculation_deduction', calc_id);
	call send_notify('calculation', calc_id, 'refresh');
end;
$$;

ALTER PROCEDURE public.make_prices_materials_relevant(calc_id uuid) OWNER TO postgres;

COMMENT ON PROCEDURE public.make_prices_materials_relevant(calc_id uuid) IS 'Приводит цены материалов калькуляции к текущим';
