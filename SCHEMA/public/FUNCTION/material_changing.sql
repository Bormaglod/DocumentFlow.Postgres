CREATE OR REPLACE FUNCTION public.material_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	wid uuid;
begin
	if (new.is_folder) then
		return new;
	end if;

	new.vat := coalesce(new.vat, 20);
	
	new.min_order := coalesce(new.min_order, 0);
	new.measurement_id := coalesce(new.measurement_id, '9f463a28-b416-4176-bf20-70cbd31786af'::uuid); -- штука

	if (new.parent_id is not null) then
		if (coalesce(old.parent_id, uuid_nil()) != new.parent_id) then
			with recursive r as
			(
				select id, parent_id, code, is_folder from material where id = new.parent_id
				union
				select p.id, p.parent_id, p.code, p.is_folder from material p join r on (r.parent_id = p.id)
			)
			select id into wid from r where is_folder and code = 'Про';

			if (wid is null) then
				new.wire_id := null;
			end if;
		end if;
	else
		new.wire_id := null;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.material_changing() OWNER TO postgres;
