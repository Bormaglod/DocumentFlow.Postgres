CREATE OR REPLACE FUNCTION public.balance_contractor_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	call send_notify('balance_contractor', old.reference_id);
	call send_notify('contractor', old.reference_id, 'refresh');

	return old;
end;
$$;

ALTER FUNCTION public.balance_contractor_deleted() OWNER TO postgres;
