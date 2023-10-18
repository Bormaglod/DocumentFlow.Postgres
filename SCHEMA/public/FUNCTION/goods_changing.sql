CREATE OR REPLACE FUNCTION public.goods_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	material_weight numeric;
begin
	new.vat := coalesce(new.vat, 20);
	
	if (new.calculation_id is not null and (old.calculation_id is null or new.calculation_id != old.calculation_id)) then
		select price 
			into new.price 
			from calculation 
			where id = new.calculation_id and state = 'approved'::calculation_state;

		if (not new.is_service) then
			select sum(cm.amount * m.weight)
				into material_weight
				from calculation_material cm 
					join calculation c ON (c.id = cm.owner_id)
					join material m on (m.id = cm.item_id)
				where 
					c.id = new.calculation_id;

			if (material_weight is not null) then
				new.weight := material_weight;
			end if;
		end if;
	end if;

	if (new.is_service) then
		new.measurement_id := null;
		new.weight := null;
	else
		new.measurement_id := coalesce(new.measurement_id, '9f463a28-b416-4176-bf20-70cbd31786af'::uuid); -- штука
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.goods_changing() OWNER TO postgres;
