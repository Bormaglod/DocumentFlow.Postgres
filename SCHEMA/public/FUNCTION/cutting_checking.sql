CREATE OR REPLACE FUNCTION public.cutting_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	program_count integer;
begin
	if (not new.is_folder) then
		if (new.program_number is not null) then
			if (new.program_number <= 0 or new.program_number > 99) then
				raise 'Необходимо указать номер программы (число от 1 до 99)';
			end if;
		
			select count(*) into program_count from cutting where program_number = new.program_number and not deleted;
			if (program_count > 1) then
				raise 'Номер этой программы (%) уже используется.', new.program_number;
			end if;
		end if;

		if (new.segment_length <= 0) then
			raise 'Необходимо указать длину резки провода';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.cutting_checking() OWNER TO postgres;
