CREATE OR REPLACE FUNCTION public.changed_account() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	bik numeric;
begin
	if (new.status_id = 1001) then
		if (new.bank_id is null) then
			raise 'Укажите банк в котором открыт данный расчётный счёт.';
		end if;

		if (new.account_value is null) then
			raise 'Укажите номер расчётного счёта.';
		end if;

		select bank.bik into bik from bank where bank.id = new.bank_id;
		if (not bank_test_account(new.account_value, bik, TG_TABLE_NAME::varchar)) then
			raise exception 'Некорректное значение расч. счёта.';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_account() OWNER TO postgres;
