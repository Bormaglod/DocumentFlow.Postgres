CREATE OR REPLACE FUNCTION public.cutting_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	root_code varchar;
	hs numeric;
	coeff integer;
	program_code varchar;
begin
	if (not new.is_folder) then
		new.manual_input = coalesce(new.manual_input, false);
		if (new.manual_input) then
			new.manual_input = false;
			return new;
		end if;
	
		new.segment_length = coalesce(new.segment_length, 0);
		new.left_cleaning = coalesce(new.left_cleaning, 0);
		new.left_sweep = coalesce(new.left_sweep, 0);
		new.right_cleaning = coalesce(new.right_cleaning, 0);
		new.right_sweep = coalesce(new.right_sweep, 0);
	
		-- Резка провода
		new.type_id = '9763903a-1a34-495a-998c-164f4d41d9fd';

		if (new.program_number is not null) then
			program_code = lpad(new.program_number::varchar, 2, '0');
		else
			program_code = 'XX';
		end if;

		new.code = 'Р' || lpad(new.segment_length::varchar, 4, '0') || program_code || lpad(new.left_cleaning::integer::varchar, 2, '0');

		if (new.left_sweep < new.left_cleaning) then
			new.code = new.code || '(' || new.left_sweep::integer || ')';
		end if;
		
		new.code = new.code || lpad(new.right_cleaning::integer::varchar, 2, '0');
		if (new.right_sweep < new.right_cleaning) then
			new.code = new.code || '(' || new.right_sweep::integer || ')';
		end if;
		
		-- Резка провода L=590мм (4мм(2мм)/5мм)
		new.item_name = 'Резка провода L=' || new.segment_length || 'мм (' || new.left_cleaning::integer || 'мм';
		if (new.left_sweep < new.left_cleaning) then
			new.item_name = new.item_name || '(' || new.left_sweep::integer || ')';
		end if;
		
		new.item_name = new.item_name || '/' || new.right_cleaning::integer || 'мм';
		if (new.right_sweep < new.right_cleaning) then
			new.item_name = new.item_name || '(' || new.right_sweep::integer || ')';
		end if;
		
		new.item_name = new.item_name || ')';

		-- p =  2636,63775 * EXP(-Length * 0,00094)
		new.produced =  round(2636.63775 * exp(-new.segment_length * 0.00094))::integer;
		new.prod_time = 3600;
		new.production_rate = new.produced;

		if (new.production_rate != 0) then
			select ot.salary / new.production_rate 
				into new.salary 
				from operation_type ot
				where ot.id = new.type_id;
		end if;
	end if;
	
	return new;
end;
$$;

ALTER FUNCTION public.cutting_changing() OWNER TO postgres;
