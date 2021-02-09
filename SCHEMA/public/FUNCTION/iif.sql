CREATE OR REPLACE FUNCTION public.iif(boolean_expression boolean, true_value money, false_value money) RETURNS money
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
	if (boolean_expression) then
    	return true_value;
	else
    	return false_value;
	end if;
end;
$$;

ALTER FUNCTION public.iif(boolean_expression boolean, true_value money, false_value money) OWNER TO postgres;

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.iif(boolean_expression boolean, true_value numeric, false_value numeric) RETURNS numeric
    LANGUAGE plpgsql IMMUTABLE
    AS $$
begin
	if (boolean_expression) then
    	return true_value;
	else
    	return false_value;
	end if;
end;
$$;

ALTER FUNCTION public.iif(boolean_expression boolean, true_value numeric, false_value numeric) OWNER TO postgres;
