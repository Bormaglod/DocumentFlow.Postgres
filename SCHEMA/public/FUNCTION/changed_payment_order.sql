CREATE OR REPLACE FUNCTION public.changed_payment_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	purchase_status integer;
begin
	-- => РАСХОД или ДОХОД
	if (new.status_id in (1200, 1201)) then 
		if (new.contractor_id is null) then
			raise 'Необходимо указать контрагента!';
		end if;
	
		if (new.amount_debited = 0::money) then
			raise 'Укажите сумму операции';
		end if;
	
		if (new.direction is null) then
			raise 'Не указано направление платежа: расход или приход.';
		end if;
	end if;

	-- => УТВЕРЖДЁН
	if (new.status_id = 1002) then
		perform add_contractor_balance(new.id, new.entity_kind_id, new.doc_number, new.contractor_id, new.amount_debited, new.date_debited, new.direction);
		if (new.purchase_id is not null) then
			select status_id into purchase_status from purchase_request where id = new.purchase_id;
			if (purchase_status not in (3002, 3004)) then
				raise 'Заявка на расход должна быть в состоянии "Получен счёт" или "Материал получен"';
			end if;
		
			if (purchase_status = 3002) then
				purchase_status = 3003;
			else
				purchase_status = 3005;
			end if;
		
			update purchase_request set status_id = purchase_status where id = new.purchase_id;
			
			perform send_notify_object('purchase_request', new.purchase_id, 'refresh');
		end if;
	
		perform send_notify_list('balance_contractor', new.contractor_id, 'refresh');
	end if;

	-- УТВЕРЖДЁН => ОТМЕНЁН
	if (old.status_id = 1002 and new.status_id = 1011) then
		perform delete_balance_contractor(new.id);
	
		if (new.purchase_id is not null) then
			select status_id into purchase_status from purchase_request where id = new.purchase_id;
			if (purchase_status = 3000) then
				raise 'Заявка на расход уже закрыта. Отменить платёжный документ не представляется возможным!';
			end if;
		
			if (purchase_status = 3003) then
				purchase_status = 3002;
			else
				purchase_status = 3004;
			end if;
		
			update purchase_request set status_id = purchase_status where id = new.purchase_id;
		
			perform send_notify_object('purchase_request', new.purchase_id, 'refresh');
		end if;
	
		perform send_notify_list('balance_contractor', new.contractor_id, 'refresh');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_payment_order() OWNER TO postgres;
