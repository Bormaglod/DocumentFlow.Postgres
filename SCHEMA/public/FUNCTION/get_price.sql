CREATE OR REPLACE FUNCTION public.get_price(object_name character varying, object_id uuid, on_date timestamp with time zone = NULL::timestamp with time zone) RETURNS money
    LANGUAGE plpgsql
    AS $$
declare
	obj_price money;
	arch_price money;
begin
	case object_name
		when 'goods' then
			select coalesce(price, 0::money) into obj_price from goods where id = object_id;
			if (on_date is not null) then
				select price_value 
					into arch_price 
					from archive_price 
					where status_id = 1100 and owner_id = object_id and on_date < date_to
					order by date_to
					limit 1;
				if (arch_price is not null) then
					obj_price = arch_price;
				end if;
			end if;
		else
        	-- nothing
	end case;

	return obj_price;
end;
$$;

ALTER FUNCTION public.get_price(object_name character varying, object_id uuid, on_date timestamp with time zone) OWNER TO postgres;

COMMENT ON FUNCTION public.get_price(object_name character varying, object_id uuid, on_date timestamp with time zone) IS 'Возвращает цену сущности на указанную дату
- наименование сущности (goods, operation_type или operation)
- object_id - идентификатор сущности
- on_date - дата/время на которую необходимо вычислить цену';
