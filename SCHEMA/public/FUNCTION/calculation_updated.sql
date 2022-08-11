CREATE OR REPLACE FUNCTION public.calculation_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.deleted) then
		call execute_system_operation(new.id, 'delete_owned'::system_operation, true, 'calculation_item');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.calculation_updated() OWNER TO postgres;
