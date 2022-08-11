CREATE OR REPLACE FUNCTION public.calculation_material_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	new_cost numeric;
begin
	if (is_system(new.owner_id, 'delete_owned'::system_operation)) then
		return new;
	end if;
	
	if (is_lock(new.owner_id)) then
		return new;
	else
		call lock_document(new.owner_id);
	end if;

	call recalculate_deduction(new.owner_id, 'material'::base_deduction);
	call set_calculation_item_cost(new.owner_id);

	call send_notify('calculation_deduction', new.owner_id);

	call unlock_document(new.owner_id);

	return new;
end;
$$;

ALTER FUNCTION public.calculation_material_changed() OWNER TO postgres;
