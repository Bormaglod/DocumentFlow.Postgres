CREATE OR REPLACE FUNCTION public.calculation_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	calc_id uuid;
	material_weight numeric;
begin
	if (new.deleted) then
		return new;
	end if;

	select calculation_id into calc_id from goods where id = new.owner_id;
	if (calc_id = new.id) then
		select sum(cm.amount * m.weight)
			into material_weight
			from calculation_material cm 
				join material m on (m.id = cm.item_id)
			where 
				cm.owner_id = new.id;

		update goods 
			set weight = material_weight,
				price = new.price
			where id = new.owner_id;
		call send_notify('goods', new.owner_id, 'refresh');
	end if;

	if (new.stimul_type != old.stimul_type or new.stimul_payment != old.stimul_payment) then
		call recalculate_items(new);
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_changed() OWNER TO postgres;
