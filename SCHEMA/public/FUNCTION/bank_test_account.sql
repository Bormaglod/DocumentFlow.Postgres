CREATE OR REPLACE FUNCTION public.bank_test_account(account numeric, bik numeric, table_name character varying) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
	bik_a integer[];
	account_a integer[];
begin
	bik_a = case table_name
		when 'bank' then string_to_array('0' || substring(lpad(bik::character varying, 9, '0') from 5 for 2), NULL)::integer[]
		when 'account' then string_to_array((bik % 1000)::character varying, NULL)::integer[]
	end;

	account_a = string_to_array(account::character varying, NULL)::integer[];
	return account_test(bik_a || account_a);
end;
$$;

ALTER FUNCTION public.bank_test_account(account numeric, bik numeric, table_name character varying) OWNER TO postgres;
