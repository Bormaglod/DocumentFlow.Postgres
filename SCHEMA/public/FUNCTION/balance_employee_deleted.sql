CREATE OR REPLACE FUNCTION public.balance_employee_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	call send_notify('balance_employee', old.reference_id);
	call send_notify('our_employee', old.reference_id, 'refresh');

	return old;
end;
$$;

ALTER FUNCTION public.balance_employee_deleted() OWNER TO postgres;
