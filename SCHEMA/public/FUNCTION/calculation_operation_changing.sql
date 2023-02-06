CREATE OR REPLACE FUNCTION public.calculation_operation_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	wire_name varchar;
	acode varchar[];
	color varchar;
	srec record;
	operation_name varchar;
	cut cutting;
begin
	if (new.deleted or is_lock(new.owner_id) or is_system(new.id, 'update'::system_operation)) then
		return new;
	end if;

	new.repeats := coalesce(new.repeats, 1);

	select item_name, salary into operation_name, new.price from operation where id = new.item_id;
	select stimul_type, stimul_payment into srec from calculation where id = new.owner_id;

	if (srec.stimul_type = 'money'::stimulating_value) then
		new.stimul_cost := srec.stimul_payment;
	else
		new.stimul_cost := new.price * srec.stimul_payment / 100;  
	end if;

	new.item_cost := (new.price + new.stimul_cost) * new.repeats;
	
	if (TG_TABLE_NAME = 'calculation_cutting') then
		if (new.material_id is not null) then 
			select item_name into wire_name from material where id = new.material_id;
			acode := string_to_array(wire_name, ' ');
			if (array_length(acode, 1) = 4) then
				color := substring(acode[4] from 1 for char_length(acode[4]) - 2) || 'ого';
				new.item_name := 'Резка ' || color || ' провода ' || acode[2] || ' ' || acode[3];
			end if;
		else
			new.item_name := 'Резка провода';
		end if;
	
		if (new.item_id is not null) then
			select * into cut from cutting where id = new.item_id;
		
			new.item_name := new.item_name || ' L=' || cut.segment_length || 'мм (' || cut.left_cleaning::integer || 'мм';
			if (cut.left_sweep < cut.left_cleaning) then
				new.item_name := new.item_name || '(' || cut.left_sweep::integer || ')';
			end if;
		
			new.item_name := new.item_name || '/' || cut.right_cleaning::integer || 'мм';
			if (cut.right_sweep < cut.right_cleaning) then
				new.item_name := new.item_name || '(' || cut.right_sweep::integer || ')';
			end if;
		
			new.item_name := new.item_name || ')';
		end if;
	else
		if (new.item_name is null) then
			if (new.item_id is not null) then
				new.item_name := operation_name;
			end if;
		end if;
	end if;

	if (new.material_id is null) then
		new.material_amount := null;
	end if;
	
	return new;
end;
$$;

ALTER FUNCTION public.calculation_operation_changing() OWNER TO postgres;
