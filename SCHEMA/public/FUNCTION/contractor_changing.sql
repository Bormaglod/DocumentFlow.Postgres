CREATE OR REPLACE FUNCTION public.contractor_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	root uuid;
begin
	if (new.subject is null) then

		with recursive r as
		(
			select id, parent_id from contractor where id = new.id
			union all 
			select c.id, c.parent_id from contractor c join r on r.parent_id = c.id
		)
		select id into root from r where parent_id is null;
	
		-- группа "Юридические лица"
		if (root = 'aee39994-7bfe-46c0-828b-ac6296103cd1') then
			new.subject := 'legal entity'::subjects_civil_low;
		
		-- группа "Физические лица"
		elseif (root = 'a9799032-2c6a-46da-ab8a-cf6423e3beb6') then
			new.subject := 'person'::subjects_civil_low;

		end if;
	
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.contractor_changing() OWNER TO postgres;
