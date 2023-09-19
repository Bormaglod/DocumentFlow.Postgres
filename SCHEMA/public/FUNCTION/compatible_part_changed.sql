CREATE OR REPLACE FUNCTION public.compatible_part_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (TG_OP = 'INSERT') then
		if (is_lock(new.compatible_id)) then
			return new;
		end if;
	
		call lock_document(new.owner_id);
	
		if (not exists(select 1 from compatible_part where owner_id = new.compatible_id and compatible_id = new.owner_id)) then 
			insert into compatible_part (owner_id, compatible_id) values (new.compatible_id, new.owner_id);
		end if;
	
		call unlock_document(new.owner_id);
	elsif (TG_OP = 'UPDATE') then
		call lock_document(new.owner_id);
		
		delete from compatible_part where owner_id = old.compatible_id and compatible_id = old.owner_id;
		if (not exists(select 1 from compatible_part where owner_id = new.compatible_id and compatible_id = new.owner_id)) then 
			insert into compatible_part (owner_id, compatible_id) values (new.compatible_id, new.owner_id);
		end if;
	
		call unlock_document(new.owner_id);
	elsif (TG_OP = 'DELETE') then
		if (is_lock(old.compatible_id)) then
			return old;
		end if;
	end if;

	if (TG_OP = 'DELETE') then
		return old;
	else
		return new;
	end if;
end;
$$;

ALTER FUNCTION public.compatible_part_changed() OWNER TO postgres;
