CREATE OR REPLACE FUNCTION public.changed_payment_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	purchase_status integer;
	invoice_status integer;
	new_invoice_status integer;
	debt numeric;
	no_pay boolean;
	new_invoice_id uuid;
begin
	-- => РАСХОД или ДОХОД
	if (new.status_id in (1200, 1201)) then 
		if (new.contractor_id is null) then
			raise 'Необходимо указать контрагента!';
		end if;
	
		if (new.amount_debited = 0) then
			raise 'Укажите сумму операции';
		end if;
	
		if (new.direction is null) then
			raise 'Не указано направление платежа: расход или приход.';
		end if;
	end if;

	-- => УТВЕРЖДЁН
	if (new.status_id = 1002) then
		perform add_contractor_balance(new.id, new.entity_kind_id, new.doc_number, new.contractor_id, new.amount_debited, new.date_debited, new.direction);
		if (new.direction = 'expense'::document_direction) then
			if (new.purchase_id is not null or new.invoice_receipt_id is not null) then 
				if (new.purchase_id is not null and new.invoice_receipt_id is not null) then
					raise 'Необходимо указать одно из двух: либо заявку на приобретение материалов, либо документ о поступлении материалов.';
				end if;
		
				if (new.purchase_id is not null) then
					select status_id into purchase_status from purchase_request where id = new.purchase_id;
					if (purchase_status != 3002) then
						raise 'Заявка на приобретение материалов должна быть в состоянии ПОЛУЧЕН СЧЁТ';
					end if;
			
					update purchase_request set status_id = status_code('invoice paid') where id = new.purchase_id;
					perform send_notify_object('purchase_request', new.purchase_id, 'refresh');
				else
					select status_id into invoice_status from invoice_receipt where id = new.invoice_receipt_id;
					if (invoice_status not in  (3004, 3006)) then
						raise 'Поступление материалов/товаров должно быть в состоянии МАТЕРИАЛ ПОЛУЧЕН или ТРЕБУЕТСЯ ДОПЛАТА';
					end if;
			
					select debt_sum from purchase_debt(new.invoice_receipt_id) into debt;
					if (debt = 0) then
						new_invoice_status = status_code('withdrawal');
					else
						new_invoice_status = status_code('payment required');
					end if;
				
					if (new_invoice_status != invoice_status) then
						update invoice_receipt set status_id = new_invoice_status where id = new.invoice_receipt_id;
						perform send_notify_object('invoice_receipt', new.invoice_receipt_id, 'refresh');
					end if;
				end if;
			end if;
		end if;
	
		perform send_notify_list('balance_contractor', new.contractor_id, 'refresh');
	end if;

	-- УТВЕРЖДЁН => ОТМЕНЁН
	if (old.status_id = 1002 and new.status_id = 1011) then
		perform delete_balance_contractor(new.id);
	
		new_invoice_id = new.invoice_receipt_id;
		if (new.purchase_id is not null) then
			select status_id into purchase_status from purchase_request where id = new.purchase_id;
			if (purchase_status = 3000) then
				raise 'Заявка на расход уже закрыта. Отменить платёжный документ не представляется возможным!';
			end if;

			-- Заявку в состоянии СЧЁТ ОПЛАЧЕН вернём в ПОЛУЧЕН СЧЁТ, в иных случаях должен быть документ Поступление товаров/материалов.
			-- Состояние именно этого документ надо будет поменять 
			if (purchase_status = status_code('invoice paid')) then
				update purchase_request set status_id = status_code('invoice recived') where id = new.purchase_id;
			else
				select id into new_invoice_id from invoice_receipt where owner_id = owner_id;
			end if;
		
			perform send_notify_object('purchase_request', new.purchase_id, 'refresh');
		end if;
	
		if (new_invoice_id is not null) then
			select status_id into invoice_status from invoice_receipt where id = new_invoice_id;
			if (invoice_status = 3000) then
				raise 'Документ "Поступление товаров/материалов" уж закрыт. Отменить платёжный документ не представляется возможным!';
			end if;
		
			select no_payment from purchase_debt(new_invoice_id) into no_pay;
			if (no_pay) then
				new_invoice_status = status_code('goods recived');
			else
				new_invoice_status = status_code('payment required');
			end if;
		
			if (new_invoice_status != invoice_status) then
				update invoice_receipt set status_id = new_invoice_status where id = new_invoice_id;
				perform send_notify_object('invoice_receipt', new_invoice_id, 'refresh');
			end if;
		end if;
	
		perform send_notify_list('balance_contractor', new.contractor_id, 'refresh');
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_payment_order() OWNER TO postgres;
