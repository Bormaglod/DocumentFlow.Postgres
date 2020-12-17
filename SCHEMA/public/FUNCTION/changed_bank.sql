CREATE OR REPLACE FUNCTION public.changed_bank() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.status_id = 1001) then
		if (new.bik is null) then
			raise 'Необходимо установить значение БИК банка';
		end if;

		if (new.account is null) then
			raise 'Необходимо установить значение корр. счёта банка';
		end if;

		if (not bank_test_account(new.account, new.bik, TG_TABLE_NAME::character varying)) then
			raise exception 'Некорректное значение БИК или корр. счета';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_bank() OWNER TO postgres;
