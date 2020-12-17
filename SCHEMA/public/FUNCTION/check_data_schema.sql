CREATE OR REPLACE FUNCTION public.check_data_schema() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	codes_equal boolean;
begin
	if (new.data_schema is not null and new.entity_kind_id is not null) then
    	select code = new.data_schema ->> 'name' 
    		into codes_equal 
        	from entity_kind
        	where id = new.entity_kind_id;
       
		codes_equal = coalesce(codes_equal, false);
		if (not codes_equal) then
    		raise exception 'Значение ключа "name" должно быть равно значению поля "code"';
    	end if;
    end if;
   
   return new;
end;
$$;

ALTER FUNCTION public.check_data_schema() OWNER TO postgres;
