CREATE OR REPLACE FUNCTION public.operations_performed_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	calc_id uuid;
begin
	select calculation_id into calc_id from production_lot where id = new.owner_id;
	if (not exists(select 1 from calculation_operation where id = new.operation_id and owner_id = calc_id)) then
		raise 'operation_id содержит значение отсутствующее в таблице calculation_operation.';
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.operations_performed_checking() OWNER TO postgres;
