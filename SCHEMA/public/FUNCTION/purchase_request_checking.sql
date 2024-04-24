CREATE OR REPLACE FUNCTION public.purchase_request_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	state_text varchar;
begin
	if (new.pstate in ('not active'::purchase_state, 'canceled'::purchase_state)) then
		state_text = case new.pstate
			when 'not active'::purchase_state then 'Не активна'
			when 'canceled'::purchase_state then 'Отменена'
		end;
	
		raise notice 'ПРОВЕРКА purchase_request. state = %', state_text;

		if (exists(select 1 from waybill_receipt where owner_id = new.id and carried_out)) then
			raise 'Заявку нельзя перевести в состояние "%", т.к. есть поступления по этой заявке.', state_text;
		end if;
	end if;

	if (old.pstate in ('canceled'::purchase_state, 'completed'::purchase_state)) then
		state_text = case old.pstate
			when 'canceled'::purchase_state then 'Отменена'
			when 'completed'::purchase_state then 'Выполнена'
		end;
	
		raise notice 'ПРОВЕРКА purchase_request. state = %', state_text;

		if (new.carried_out != old.carried_out) then
			raise 'Нельзя изменить статус проведения заявки в состоянии "%".', state_text;
		end if;
	end if;

	if (new.pstate = 'completed'::purchase_state) then
		if (not new.carried_out) then
			raise 'Завершить заявку можно, но сначала надо документ провести.';
		end if;
	
		if (not exists(select 1 from waybill_receipt where owner_id = new.id and carried_out)) then
			raise 'Заявку нельзя завершить, т.к. по ней нет поступлений.';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.purchase_request_checking() OWNER TO postgres;
