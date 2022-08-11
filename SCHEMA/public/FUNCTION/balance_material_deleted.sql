CREATE OR REPLACE FUNCTION public.balance_material_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	call rebuild_balance_material(old.reference_id, old.document_date);
	call send_notify('balance_material', old.reference_id);
	call send_notify('material', old.reference_id, 'refresh');

	return old;
end;
$$;

ALTER FUNCTION public.balance_material_deleted() OWNER TO postgres;
