CREATE OR REPLACE FUNCTION public.purchase_request_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (old.state_id != new.state_id) then
	
	else
		if (not is_system(new.id, 'lock_reaccept'::system_operation)) then
			if (new.carried_out) then
				new.pstate = 'active'::purchase_state;
			else
				if (old.carried_out) then
					new.pstate = 'not active'::purchase_state;
				end if;
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.purchase_request_changing() OWNER TO postgres;
