CREATE OR REPLACE FUNCTION public.operations_performed_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	op_price numeric;
begin
	select price + stimul_cost into op_price from calculation_operation where id = new.operation_id;

	new.double_rate := extract(isodow from new.document_date) in (6, 7);
	new.salary := coalesce(new.quantity * op_price, 0);

	if (new.double_rate) then
		new.salary := new.salary * 2;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.operations_performed_changing() OWNER TO postgres;
