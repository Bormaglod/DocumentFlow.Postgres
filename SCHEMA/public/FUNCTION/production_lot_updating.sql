CREATE OR REPLACE FUNCTION public.production_lot_updating() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	prod_started bool;
begin
	if (new.carried_out != old.carried_out) then
		prod_started := exists(select 1 from operations_performed where owner_id = new.id and carried_out);
		if (prod_started) then
			new.pstate := 'production'::lot_state;
		else
			new.pstate := 'created'::lot_state;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.production_lot_updating() OWNER TO postgres;
