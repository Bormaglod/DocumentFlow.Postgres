CREATE OR REPLACE FUNCTION public.initial_balance_contractor_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	start_date timestamptz;
begin
	if (new.carried_out != old.carried_out) then
		if (new.carried_out) then
			if (new.operation_summa = 0) then
				raise 'Сумма остатка не должна быть равна 0.';
			end if;
		
			if (new.amount = 0) then
				raise 'Должен быть указан тип долга (наш или контрагента)';
			end if;
		
			if (exists(select * from balance_contractor where reference_id = new.reference_id and document_type_id = '363fcd46-a9dd-4da0-a1c4-0dfb8cc33e16')) then
				raise 'По контрагенту % уже заведены остатки. Провести документ нельзя',
					(select item_name from contractor where id = new.reference_id);
			end if;
		
			select min(document_date) into start_date from balance_contractor where reference_id = new.reference_id;
			if (new.document_date >= start_date) then
				raise 'Дата начального остатка должна самой ранней';
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.initial_balance_contractor_checking() OWNER TO postgres;
