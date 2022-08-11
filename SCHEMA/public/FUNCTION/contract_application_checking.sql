CREATE OR REPLACE FUNCTION public.contract_application_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	ds date;
	de date;
begin
	select date_start, date_end into ds, de from contract where id = new.owner_id;

	if (new.date_end is not null and new.date_end <= new.date_start) then
		raise 'Дата окончания действия приложения к договору не может быть раньше даты начала действия.';
	end if;

	if (new.date_start < ds or new.date_start > de) then
		raise 'Дата начала действия приложения должна укладываться в диапазон действия договора.';
	end if;

	if (new.date_end is not null) then
		if (new.date_end < ds or new.date_end > de) then
			raise 'Дата окончания действия приложения должна укладываться в диапазон действия договора.';
		end if;
	else
		if (de is not null) then
			raise 'Договором предусмотрена дата окончания действия. У приложения тоже должна быть указана дата окончания дйствия приложения.';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.contract_application_checking() OWNER TO postgres;
