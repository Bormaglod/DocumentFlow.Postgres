CREATE OR REPLACE FUNCTION public.product_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	calc record;
	material_weight numeric;
	wid uuid;
begin
	if (new.is_folder) then
		return new;
	end if;

	new.vat := coalesce(new.vat, 20);
	
	if (TG_TABLE_NAME::varchar = 'material') then
		new.min_order := coalesce(new.min_order, 0);
		new.measurement_id := coalesce(new.measurement_id, '9f463a28-b416-4176-bf20-70cbd31786af'::uuid); -- штука

		if (new.parent_id is not null) then
			if (coalesce(old.parent_id, uuid_nil()) != new.parent_id) then
				with recursive r as
				(
					select id, parent_id, code, is_folder from material where id = new.parent_id
					union
					select p.id, p.parent_id, p.code, p.is_folder from material p join r on (r.parent_id = p.id)
				)
				select id into wid from r where is_folder and code = 'Про';
		
				if (wid is null) then
					new.wire_id := null;
				end if;
			end if;
		else
			new.wire_id := null;
		end if;
	end if;
		
	if (TG_TABLE_NAME::varchar = 'goods') then
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
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.product_changing() OWNER TO postgres;
