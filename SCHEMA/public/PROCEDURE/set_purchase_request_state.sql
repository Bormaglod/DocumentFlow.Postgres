CREATE OR REPLACE PROCEDURE public.set_purchase_request_state(purchase_request_id uuid, p_state public.purchase_state)
    LANGUAGE plpgsql
    AS $$
declare
	co boolean;
begin
	if (p_state not in ('canceled'::purchase_state, 'completed'::purchase_state)) then
		raise 'Заявку можно либо отменить, либо заверщить.';
	end if;

	select carried_out into co from purchase_request where id = purchase_request_id;

	if (p_state = 'completed'::purchase_state) then
		-- если заявку завершаем, а она не проведена, то пробуем её провести
		if (not co) then
			call execute_system_operation(purchase_request_id, 'accept'::system_operation, true, 'purchase_request');
		end if;
	else
		-- если заявку отменяем, а она проведена, то проведение тоже отменяем
		if (co) then
			call execute_system_operation(purchase_request_id, 'accept'::system_operation, false, 'purchase_request');
		end if;
	end if;

	call set_system_value(purchase_request_id, 'lock_reaccept'::system_operation);
	update purchase_request 
		set pstate = p_state
		where id = purchase_request_id;
	call clear_system_value(purchase_request_id);
end;
$$;

ALTER PROCEDURE public.set_purchase_request_state(purchase_request_id uuid, p_state public.purchase_state) OWNER TO postgres;
