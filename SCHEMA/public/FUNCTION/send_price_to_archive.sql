CREATE OR REPLACE FUNCTION public.send_price_to_archive() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	price_id uuid;
	price_prev numeric;
	price_new numeric;
begin
	if (TG_TABLE_NAME not in ('goods', 'operation_type', 'operation')) then
		raise 'Для таблицы % не предусмотрен архив цен!', TG_TABLE_NAME;
	end if;

	if (new.status_id = 1004) then
		if (TG_TABLE_NAME = 'goods') then
			price_prev = old.price;
		elseif (TG_TABLE_NAME = 'operation_type') then
			price_prev = old.hourly_salary;
		elseif (TG_TABLE_NAME = 'operation') then
			price_prev = old.salary;
		end if;
	
		if (price_prev != 0) then
			insert into archive_price (owner_id, price_value) values (old.id, price_prev);
		end if;
	end if;

	if (new.status_id = 1002) then
		select id, price_value 
			into price_id, price_prev 
			from archive_price 
			where 
				owner_id = new.id and
				status_id = 1000
			order by date_created desc limit 1;
		
		if (not price_id is null) then
			if (TG_TABLE_NAME = 'goods') then
				price_new = new.price;
			elseif (TG_TABLE_NAME = 'operation_type') then
				price_new = new.hourly_salary;
			elseif (TG_TABLE_NAME = 'operation') then
				price_new = new.salary;
			end if;
		
			if (price_prev = price_new) then
				delete from archive_price where id = price_id;
			else
				update archive_price set status_id = 1100 where id = price_id;
				perform send_notify_list('archive_price', new.id, 'refresh');
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.send_price_to_archive() OWNER TO postgres;
