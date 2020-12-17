CREATE OR REPLACE FUNCTION public.account_test(account integer[]) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
	k integer[] := '{ 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1 }';
	summa integer;
begin
	if (array_length(account, 1) != 23) then
		return false;
	end if;

	summa := control_sum(account, k);
	return summa % 10 = 0;
end;
$$;

ALTER FUNCTION public.account_test(account integer[]) OWNER TO postgres;
