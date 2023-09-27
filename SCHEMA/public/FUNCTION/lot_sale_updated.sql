CREATE OR REPLACE FUNCTION public.lot_sale_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	lot_info record;
	lot_sold numeric;
	lot uuid;
	new_sold boolean;
	do_update boolean;
begin
	if (TG_OP = 'DELETE') then
		lot = old.lot_id;
	else
		lot = new.lot_id;
	end if;

	select quantity, sold into lot_info from production_lot where id = lot;
	select sum(quantity) into lot_sold from lot_sale where lot_id = lot;

	lot_sold := coalesce(lot_sold, 0);

	do_update := false;
	if (lot_sold = 0) then
		new_sold := false;
		do_update := coalesce(lot_info.sold, true);
	elsif (lot_sold = lot_info.quantity) then
		new_sold := true;
		do_update := coalesce(not lot_info.sold, true);
	else
		new_sold := null;
		do_update := lot_info.sold is not null;
	end if;

	if (do_update) then
		call set_system_value(lot, 'lock_reaccept'::system_operation);
		update production_lot set sold = new_sold where id = lot;
		call clear_system_value(lot);
	end if;
	
	if (TG_OP = 'DELETE') then
		return old;
	else
		return new;
	end if;
end;
$$;

ALTER FUNCTION public.lot_sale_updated() OWNER TO postgres;
