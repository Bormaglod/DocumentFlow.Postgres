CREATE OR REPLACE PROCEDURE public.set_production_lot_state(document_id uuid, document_state public.lot_state)
    LANGUAGE plpgsql
    AS $$
begin
	call set_system_value(document_id, 'lock_reaccept'::system_operation);
	update production_lot set state = document_state where id = document_id;
	call clear_system_value(document_id);

	call send_notify('production_lot');
	call send_notify('production_lot', document_id);
	call send_notify('production_lot', document_id, 'refresh');
end;
$$;

ALTER PROCEDURE public.set_production_lot_state(document_id uuid, document_state public.lot_state) OWNER TO postgres;
