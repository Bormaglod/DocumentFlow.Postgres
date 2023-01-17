CREATE OR REPLACE FUNCTION public.account_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	bik numeric;
begin
	if (new.bank_id is not null) then
		select bank.bik into bik from bank where bank.id = new.bank_id;
		if (new.account_value > 0 and not bank_test_account(new.account_value, bik, TG_TABLE_NAME::varchar)) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Некорректное значение расч. счёта.');
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.account_checking() OWNER TO postgres;
