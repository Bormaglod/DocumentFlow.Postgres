CREATE OR REPLACE FUNCTION public.calculation_operation_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	new_cost numeric;
	rec record;
begin
	raise notice 'START calculation_operation_changed() with id = %', new.id;

	if (is_system(new.id, 'update'::system_operation) or is_system(new.owner_id, 'delete_owned'::system_operation)) then
		return new;
	end if;

	if (is_lock(new.owner_id)) then
		return new;
	else
		call lock_document(new.owner_id);
	end if;

	if (coalesce(old.material_id, new.material_id) is not null or old.deleted != new.deleted) then
		if (old.material_id is not null) then
			call recalculate_amount_material(new.owner_id, old.material_id);
		end if;

		if (new.material_id is not null) then
			if (old.material_id is null or new.material_id != old.material_id) then
				call recalculate_amount_material(new.owner_id, new.material_id);
			end if;
		end if;

		call send_notify('calculation_material', new.owner_id);
	
		call recalculate_deduction(new.owner_id, 'material'::base_deduction);
	end if;
	
	call recalculate_deduction(new.owner_id, 'salary'::base_deduction);
	call set_calculation_item_cost(new.owner_id);

	call send_notify('calculation_deduction', new.owner_id);

	call unlock_document(new.owner_id);

	if (old.code is null or new.code != old.code) then
		-- при изменении кода операции, необходимо сделать замену этого кода в 
		-- поле previous_operation зависимых операций
		if (old.code is not null) then
			for rec in
				select 
					id, 
					code, 
					item_name, 
					previous_operation, 
					array_position(previous_operation, old.code) as code_position, 
					tableoid::regclass::varchar as table_name
				from calculation_operation 
				where owner_id = new.owner_id and array_position(previous_operation, old.code) is not null
			loop 
				call set_system_value(rec.id, 'update'::system_operation);
				
				update calculation_operation 
					set previous_operation = array_replace(rec.previous_operation, old.code, new.code)
					where id = rec.id;
				
				call clear_system_value(rec.id);
				
				call send_notify(rec.table_name, rec.id, 'refresh');
			end loop;
		end if;
	end if;

	-- сообщим об обновлении всех строк, где используется эта операция
	if (new.previous_operation is not null and (old.previous_operation is null or old.previous_operation != new.previous_operation)) then
		for rec in
			with op as 
			(
				select unnest(previous_operation) as code
					from calculation_operation
					where id = new.id
			)
			select co.id, op.*, co.tableoid::regclass::varchar as table_name
				from op
					join calculation_operation co on (co.code = op.code and co.owner_id = new.owner_id)
		loop
			call send_notify(rec.table_name, rec.id, 'refresh');
		end loop;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_operation_changed() OWNER TO postgres;
