CREATE OR REPLACE FUNCTION public.calculation_deduction_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	deduction_rec record;
	cost_material numeric;
	cost_operation numeric;
	old_item uuid;
begin
	if (new.deleted or is_lock(new.owner_id)) then
		return new;
	end if;

	new.price := coalesce(new.price, 0);
	new.value := coalesce(new.value, 0);

	old_item := coalesce(old.item_id, uuid_nil());
	if (new.item_id is not null and new.item_id != old_item) then
		select base_calc, value into deduction_rec from deduction where id = new.item_id;
		if (deduction_rec.base_calc = 'person'::base_deduction) then
			new.price := deduction_rec.value;
			new.value := 100;
		
			if (new.item_cost = 0) then
				new.item_cost := deduction_rec.value;
			end if;
		else
			if (deduction_rec.base_calc = 'material'::base_deduction) then
				select sum(item_cost) into new.price from calculation_material where owner_id = new.owner_id and not deleted;
			else
				select sum(item_cost) into new.price from calculation_operation co where owner_id = new.owner_id and not deleted;
			end if;

			new.value := deduction_rec.value;
		
			new.item_cost := new.price * new.value / 100;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_deduction_changing() OWNER TO postgres;
