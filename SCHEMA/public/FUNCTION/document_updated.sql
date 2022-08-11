CREATE OR REPLACE FUNCTION public.document_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	change_number boolean;
	change_date boolean;
begin
	change_number = false;
	change_date = true;
	
	if (coalesce(old.document_number, new.document_number) is not null) then
		change_number = old.document_number != new.document_number;
	end if;

	if (coalesce(old.document_date, new.document_date) is not null) then
		change_date = old.document_date != new.document_date;
	end if;

	if (change_number or change_date) then
		update balance
			set document_number = new.document_number,
				document_date = new.document_date
			where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.document_updated() OWNER TO postgres;
