CREATE OR REPLACE FUNCTION public.contract_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.date_end is not null and new.date_end <= new.date_start) then
		raise 'Дата окончания действия договора не может быть раньше даты начала действия.';
	end if;

	if (new.date_start != old.date_start) then
		if (exists(select *	from contract_application where owner_id = new.id and date_start < new.date_start)) then
			raise 'Дата начала договора не должна быть позже даты начала действия приложения (любого) к договору.';
		end if;
	end if;

	if (new.date_end is not null and new.date_end != old.date_end) then
		if (exists(select *	from contract_application where owner_id = new.id and date_end is not null and date_end > new.date_end)) then
			raise 'Дата окончания договора не должна быть раньше даты окончания действия приложения (любого) к договору.';
		end if;
			
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.contract_checking() OWNER TO postgres;
