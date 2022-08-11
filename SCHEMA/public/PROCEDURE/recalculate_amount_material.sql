CREATE OR REPLACE PROCEDURE public.recalculate_amount_material(calc_id uuid, calc_update boolean = true)
    LANGUAGE plpgsql
    AS $$
declare
	unlock_needed bool;
begin
	unlock_needed := not is_lock(calc_id);
	if (unlock_needed) then
		call lock_document(calc_id);
	end if;

	update calculation_material
		set amount = total.materials
		from (
			select co.material_id, sum(co.material_amount * coalesce(co.repeats, 1)) as materials 
				from calculation_operation co
					join calculation c on (c.id = co.owner_id)
					join operation o on (o.id = co.item_id)
				where c.id = calc_id and co.material_id is not null 
				group by co.material_id
		) total
		where item_id = total.material_id and not deleted and owner_id = calc_id;
	
	if (unlock_needed) then
		call unlock_document(calc_id);
	end if;
	
	if (calc_update) then
		call recalculate_deduction(calc_id, 'material'::base_deduction);
		call set_calculation_item_cost(calc_id);
	end if;
end;
$$;

ALTER PROCEDURE public.recalculate_amount_material(calc_id uuid, calc_update boolean) OWNER TO postgres;

COMMENT ON PROCEDURE public.recalculate_amount_material(calc_id uuid, calc_update boolean) IS 'Пересчёт всего количества материала используемого в калькуляции';

--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE public.recalculate_amount_material(calc_id uuid, mat_id uuid)
    LANGUAGE plpgsql
    AS $$
declare
	total_material numeric;
	mid uuid;
begin
	select sum(co.material_amount * co.repeats) 
		into total_material 
		from calculation_operation co
			join calculation c on (c.id = co.owner_id)
			join operation o on (o.id = co.item_id)
		where c.id = calc_id and co.material_id = mat_id and not co.deleted;

	if (coalesce(total_material, 0) = 0) then
		select id into mid from calculation_material where owner_id = calc_id and item_id = mat_id;
		if (mid is not null) then
			update calculation_material set deleted = true where id = mid;
			delete from calculation_material where id = mid;
		end if;
	else
		insert into calculation_material (owner_id, item_id, amount)
			values (calc_id, mat_id, total_material)
			on conflict (owner_id, item_id) where not deleted
			do update set
				owner_id = calc_id,
				item_id = mat_id,
				amount = total_material;
	end if;
end;
$$;

ALTER PROCEDURE public.recalculate_amount_material(calc_id uuid, mat_id uuid) OWNER TO postgres;

COMMENT ON PROCEDURE public.recalculate_amount_material(calc_id uuid, mat_id uuid) IS 'Процедура пересчитывает количество указанного материала задействованого в калькуляции.';
