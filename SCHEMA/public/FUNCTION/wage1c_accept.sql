CREATE OR REPLACE FUNCTION public.wage1c_accept() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.carried_out) then
	
	else

	end if;

	return new;
end;
$$;

ALTER FUNCTION public.wage1c_accept() OWNER TO postgres;
