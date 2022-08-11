CREATE OR REPLACE FUNCTION public.calculation_deduction_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (is_system(new.owner_id, 'delete_owned'::system_operation) or is_lock(new.owner_id)) then
		return new;
	end if;

	call set_calculation_item_cost(new.owner_id);

	return new;
end;
$$;

ALTER FUNCTION public.calculation_deduction_changed() OWNER TO postgres;
