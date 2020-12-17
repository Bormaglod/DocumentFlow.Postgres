CREATE OR REPLACE FUNCTION public.control_sum(source integer[], coeff integer[]) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
   summa integer;
   m integer;
begin
   m := min_int(array_length(source, 1), array_length(coeff, 1));

   summa := 0;
   for i in 1 .. m loop
      summa := summa + source[i] * coeff[i];
   end loop;
	
   return summa;
end;
$$;

ALTER FUNCTION public.control_sum(source integer[], coeff integer[]) OWNER TO postgres;
