CREATE OR REPLACE FUNCTION public.operation_type_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	update operation as o
		set salary = new.salary / production_rate,
			manual_input = true
		from op
		where o.id = op.id;
	
	if (new.id = '9763903a-1a34-495a-998c-164f4d41d9fd') then 
		-- резка проводов
		call send_notify('cutting');
	else
		call send_notify('operation');
	end if;
	
	return new;
end;
$$;

ALTER FUNCTION public.operation_type_changed() OWNER TO postgres;
