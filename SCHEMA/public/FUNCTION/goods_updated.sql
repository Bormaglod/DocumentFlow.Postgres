CREATE OR REPLACE FUNCTION public.goods_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	last_mod_number integer;
	calc_info record;
begin
	if (new.code != old.code) then 
		select max(substring(code from '.+\/(\d+)')::integer) into last_mod_number from calculation c where owner_id = new.id;
		last_mod_number := coalesce(last_mod_number, 0);
		
		for calc_info in
			select id, substring(code from '.+\/(\d+)') as mod_number from calculation c where owner_id = new.id
		loop
			if (calc_info.mod_number is null) then 
				last_mod_number := last_mod_number + 1;
				calc_info.mod_number := last_mod_number;
			end if;
		
			call set_system_value(calc_info.id, 'change_code'::system_operation);
			update calculation 
				set code = new.code || '/' || calc_info.mod_number
				where id = calc_info.id;
			call clear_system_value(calc_info.id);
		end loop;
		
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.goods_updated() OWNER TO postgres;
