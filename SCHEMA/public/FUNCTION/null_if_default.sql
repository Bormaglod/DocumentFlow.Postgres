CREATE OR REPLACE FUNCTION public.null_if_default(numeric_value numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
begin
	return 
    	case 
   			when numeric_value = 0 then null
			else numeric_value
		end;
end;
$$;

ALTER FUNCTION public.null_if_default(numeric_value numeric) OWNER TO postgres;
