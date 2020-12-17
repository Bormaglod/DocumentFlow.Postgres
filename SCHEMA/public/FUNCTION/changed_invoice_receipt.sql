CREATE OR REPLACE FUNCTION public.changed_invoice_receipt() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	invoice_cost money;
	purchase_status integer;
	rgoods record;
	balance_id uuid;
begin
	-- => УТВЕРДИТЬ
	if (new.status_id = 1002) then
		select sum(cost_with_tax) into invoice_cost from invoice_receipt_detail where owner_id = new.id;

		perform add_contractor_balance(new.id, new.entity_kind_id, new.doc_number, new.contractor_id, invoice_cost, new.receipt_date, 'income'::document_direction);
		if (new.owner_id is not null) then
			select status_id into purchase_status from purchase_request where id = new.owner_id;
			if (purchase_status not in (1001, 3001, 3002, 3003)) then
				raise 'Заявка на расход должна быть в состоянии "Корректен", "Отправлен", "Получен счёт" или "Счёт оплачен"';
			end if;
		
			if (purchase_status = 3003) then
				purchase_status = 3005;
			else
				purchase_status = 3004;
			end if;
		
			update purchase_request set status_id = purchase_status where id = new.owner_id;
			perform send_notify_object('purchase_request', new.owner_id, 'refresh');
		end if;
		
		perform send_notify_list('balance_contractor', new.contractor_id, 'refresh');
	
		for rgoods in
			select goods_id, amount, cost from invoice_receipt_detail where owner_id = new.id
		loop
			perform goods_balance_receipt(new.id, new.entity_kind_id, new.doc_number, rgoods.goods_id, rgoods.amount, rgoods.cost, new.receipt_date);
			perform send_notify_list('balance_goods', rgoods.goods_id, 'refresh');
		end loop;
	end if;

	-- УТВЕРЖДЕН => ОТМЕНЕН или ИЗМЕНЯЕТСЯ
	if (old.status_id = 1002 and new.status_id in (1004, 1011)) then
		if (new.owner_id is not null) then
			select status_id into purchase_status from purchase_request where id = new.owner_id;
			if (purchase_status = 3000) then
				raise 'Заявка на расход уже закрыта. Отменить платёжный документ не представляется возможным!';
			end if;
		
			-- если состояние заявки - "Материал получен и оплачен", то вернём её в состояние "Счёт оплачен",
			-- иначе определим предыдущее состояние заявки в которое и попытаемся её установить.
			if (purchase_status = 3005) then
				purchase_status = 3003;
			else
				purchase_status = null;
				select from_status_id into purchase_status from history where reference_id = new.owner_id order by changed desc limit 1;
				if (purchase_status is null) then
					raise 'Обнаружено неопределенное предыдущее состояние заявки на расход! Необходимо вмешательство администратора';
				end if;
			
				update purchase_request set status_id = purchase_status where id = new.owner_id;
				perform send_notify_object('purchase_request', new.owner_id, 'refresh');
			end if;
		end if;
	
		perform delete_balance_contractor(new.id);
		perform send_notify_list('balance_contractor', new.contractor_id, 'refresh');
	
		perform delete_balance_goods(new.id);
		for rgoods in
			select goods_id from invoice_receipt_detail where owner_id = new.id
		loop
			perform send_notify_list('balance_goods', rgoods.goods_id, 'refresh');
		end loop;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_invoice_receipt() OWNER TO postgres;
