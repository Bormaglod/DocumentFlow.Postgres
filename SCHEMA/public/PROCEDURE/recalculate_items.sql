CREATE OR REPLACE PROCEDURE public.recalculate_items(calc public.calculation, calc_update boolean = true)
    LANGUAGE plpgsql
    AS $$
declare
	op record;
	item_price numeric;
	stimul numeric;
	material_cost numeric;
	salary_cost numeric;
	cd_value numeric;
begin
	call lock_document(calc.id);

	for op in
		select 
			co.*,
			o.salary
		from calculation_operation co 
			join operation o on (o.id = co.item_id)
		where co.owner_id = calc.id and not co.deleted
	loop
		item_price = op.salary;
	
		if (calc.stimul_type = 'money'::stimulating_value) then
			stimul = calc.stimul_payment;
		else
			stimul = item_price * calc.stimul_payment / 100;  
		end if;
	
		update calculation_operation
			set price = item_price,
				stimul_cost = stimul,
				item_cost = (item_price + stimul) * op.repeats
			where id = op.id;
	end loop;

	call recalculate_amount_material(calc.id, false);

	select sum(item_cost) into material_cost from calculation_material where owner_id = calc.id and not deleted;
	select sum(item_cost) into salary_cost from calculation_operation co where owner_id = calc.id and not deleted;

	for op in
		select 
			cd.*,
			d.base_calc,
			d.value as deduction_value
		from calculation_deduction cd 
			join deduction d on (d.id = cd.item_id)
		where cd.owner_id = calc.id and not cd.deleted
	loop 
		if (op.base_calc = 'person'::base_deduction) then
			item_price = op.deduction_value;
			cd_value = 100;
		else
			if (op.base_calc = 'material'::base_deduction) then
				item_price = material_cost;
			else
				item_price = salary_cost;
			end if;

			cd_value = op.deduction_value;
		end if;
	
		update calculation_deduction
			set price = item_price,
				value = cd_value,
				item_cost = item_price * cd_value / 100
			where id = op.id;
	end loop;

	if (calc_update) then
		call set_calculation_item_cost(calc.id);
	end if;

	call unlock_document(calc.id);
end;
$$;

ALTER PROCEDURE public.recalculate_items(calc public.calculation, calc_update boolean) OWNER TO postgres;
