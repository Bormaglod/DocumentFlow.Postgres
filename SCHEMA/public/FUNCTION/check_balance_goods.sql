CREATE OR REPLACE FUNCTION public.check_balance_goods() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (TG_TABLE_NAME = 'balance_goods') then
		if (new.status_id != 1000 and (new.operation_summa = 0::money or new.amount <= 0::numeric)) then
    		raise 'Сумма операции должна быть отлична от 0, а количество больше 0.';
	    end if;
    end if;
    
    if (TG_TABLE_NAME = 'balance_tolling') then
    	if (new.status_id != 1000 and new.amount <= 0::numeric) then
    		raise 'Количество материала должно быть больше 0.';
	    end if;
    end if;
    
    return new;
end;
$$;

ALTER FUNCTION public.check_balance_goods() OWNER TO postgres;
