CREATE OR REPLACE FUNCTION public.min_int(left_value integer, right_value integer) RETURNS integer
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
   m integer;
begin
   if (left_value < right_value) then
      m = left_value;
   else
      m = right_value;
   end if;

   return m;
end;
$$;

ALTER FUNCTION public.min_int(left_value integer, right_value integer) OWNER TO postgres;
