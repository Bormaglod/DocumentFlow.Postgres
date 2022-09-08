CREATE OR REPLACE FUNCTION public.payroll_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.carried_out) then
	
	else
	
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.payroll_accept() OWNER TO postgres;
