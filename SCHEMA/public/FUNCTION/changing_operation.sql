CREATE OR REPLACE FUNCTION public.changing_operation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	root_code varchar;
	hs numeric;
	coeff integer;
	program_code varchar;
begin
	if (new.status_id = 1001) then
		with recursive r as (
			select id, parent_id, code
				from operation
				where id = new.id
			union
			select operation.id, operation.parent_id, operation.code
				from operation
					join r on operation.id = r.parent_id
		)
		select r.code into root_code from r where r.parent_id is null;

		if (new.type_id is null) then
			raise 'Необходимо указать тип операции';
		end if;
	
		if (new.measurement_id is null) then
			new.measurement_id = '9f463a28-b416-4176-bf20-70cbd31786af'; -- штука
		end if;
	
		select coefficient into coeff from measurement where id = new.measurement_id;
	
		new.length = coalesce(new.length, 0);
		new.left_cleaning = coalesce(new.left_cleaning, 0);
		new.left_sweep = coalesce(new.left_sweep, 0);
		new.right_cleaning = coalesce(new.right_cleaning, 0);
		new.right_sweep = coalesce(new.right_sweep, 0);
	
		if (root_code = 'Резка') then
			if (new.program is not null) then
				if (new.type_id = '9763903a-1a34-495a-998c-164f4d41d9fd' and new.program <= 0 or new.program > 99) then
					raise 'Необходимо указать номер программы (число от 1 до 99)';
				end if;
		
				if (exists (select id from operation where program = new.program and type_id = '9763903a-1a34-495a-998c-164f4d41d9fd' and status_id = 1002)) then
					raise 'Номер этой программы уже используется.';
				end if;
			
				program_code = lpad(new.program::varchar, 2, '0');
			else
				program_code = 'XX';
			end if;
		
			if (new.length <= 0) then
				raise 'Необходимо указать длину резки провода';
			end if;

			new.code = 'Р' || lpad(new.length::varchar, 4, '0') || program_code || lpad(new.left_cleaning::integer::varchar, 2, '0');

			if (new.left_sweep < new.left_cleaning) then
				new.code = new.code || '(' || new.left_sweep::integer || ')';
			end if;
		
			new.code = new.code || lpad(new.right_cleaning::integer::varchar, 2, '0');
			if (new.right_sweep < new.right_cleaning) then
				new.code = new.code || '(' || new.right_sweep::integer || ')';
			end if;
		
			-- Резка провода L=590мм (4мм(2мм)/5мм)
			new.name = 'Резка провода L=' || new.length || 'мм (' || new.left_cleaning::integer || 'мм';
			if (new.left_sweep < new.left_cleaning) then
				new.name = new.name || '(' || new.left_sweep::integer || ')';
			end if;
		
			new.name = new.name || '/' || new.right_cleaning::integer || 'мм';
			if (new.right_sweep < new.right_cleaning) then
				new.name = new.name || '(' || new.right_sweep::integer || ')';
			end if;
		
			new.name = new.name || ')';
		
			-- 2636,63775 * EXP(-Length * 0,00094)
			new.produced =  round(2636.63775 * exp(-new.length * 0.00094))::integer;
			new.prod_time = 3600;
			new.production_rate = new.produced;
		else
			new.program = null;
		
			if (new.produced <= 0) then
				raise 'Выработка должна быть больше 0.';
			end if;
		
			if (new.prod_time <= 0) then
				raise 'Время выработки должно быть больше 0.';
			end if;
		
			new.production_rate = new.produced * 3600 / new.prod_time;
		end if;

		select hourly_salary * coeff / new.production_rate into new.salary from operation_type where id = new.type_id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_operation() OWNER TO postgres;
