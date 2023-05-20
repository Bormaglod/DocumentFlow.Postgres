CREATE OR REPLACE FUNCTION public.compatible_part_changed() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (TG_OP in ('UPDATE', 'DELETE')) then
		delete from compatible_part where owner_id = old.compatible_id and compatible_id = old.owner_id;
	end if;

	if (TG_OP in ('INSERT', 'UPDATE')) then
		if (not exists(select 1 from compatible_part where owner_id = new.compatible_id and compatible_id = new.owner_id)) then 
			insert into compatible_part (owner_id, compatible_id) values (new.compatible_id, new.owner_id);
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
