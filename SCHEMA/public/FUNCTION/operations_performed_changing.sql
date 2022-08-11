CREATE OR REPLACE FUNCTION public.operations_performed_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	op_price numeric;
begin
	select price into op_price from calculation_operation where id = new.operation_id;
	new.salary = coalesce(new.quantity * op_price, 0);

	return new;
end;
$$;

ALTER FUNCTION public.operations_performed_changing() OWNER TO postgres;
