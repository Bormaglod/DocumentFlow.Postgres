CREATE OR REPLACE FUNCTION public.bank_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.bik > 0 and new.account > 0 and not bank_test_account(new.account, new.bik, TG_TABLE_NAME::character varying)) then
		raise exception 'Некорректное значение БИК или корр. счета';
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.bank_checking() OWNER TO postgres;
