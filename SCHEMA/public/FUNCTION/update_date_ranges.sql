CREATE OR REPLACE FUNCTION public.update_date_ranges() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (old.status_id = 1000 and new.status_id = 1100) then
		new.date_to = new.date_updated;
	end if;
	
	if (new.status_id = 1100) then
		if (new.date_to is null) then
			raise 'Дата окончания действия цены должна быть указана обязательно.';
		end if;

		perform send_notify_list('archive_price', new.owner_id, 'refresh');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.update_date_ranges() OWNER TO postgres;
