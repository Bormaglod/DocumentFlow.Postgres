CREATE OR REPLACE FUNCTION public.purchase_request_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (not is_system(new.id, 'lock_reaccept'::system_operation)) then
		if (new.carried_out) then
			new.state = 'active'::purchase_state;
		else
			if (old.carried_out) then
				new.state = 'not active'::purchase_state;
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.purchase_request_changing() OWNER TO postgres;
