CREATE OR REPLACE FUNCTION public.changed_invoice_receipt() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	invoice_cost money;
	purchase_status integer;
	rgoods record;
	balance_id uuid;
	ctype contractor_type;
	is_tax boolean;
	count_rows bigint;
begin
	-- СОСТАВЛЕН или ИЗМЕНЯЕТСЯ => КОРРЕКТЕН
	if (old.status_id in (1000, 1004) and new.status_id = 1001) then
		if (new.contractor_id is null) then
			raise 'Необходимо указать контрагента!';
		end if;
	
		if (new.contract_id is null) then
			raise 'Необходимо указать договор!';
		end if;
	
		select tax_payer into is_tax from contract where id = new.contract_id;
		if (is_tax) then
			if (new.invoice_number is null) then
				raise 'Укажите номер входной счёт-фактуры.';
			end if;
		
			if (new.invoice_date is null) then
				raise 'Укажите дату входной счёт-фактуры.';
			end if;
		end if;
	
		select count(*) into count_rows from invoice_receipt_detail where owner_id = new.id;
		if (count_rows = 0) then
			raise 'Заполните табличную часть!';
		end if;
	end if;

	-- КОРРЕКТЕН => МАТЕРИАЛ ПОЛУЧЕН, МАТЕРИАЛ ПОЛУЧЕН И ОПЛАЧЕН или ТРЕБУЕТСЯ ДОПЛАТА
	if (old.status_id = 1001 and new.status_id in (3004, 3005, 3006)) then
		-- увеличим задолженность поставщику, если мы купили материал, а не получили как давальческий
        if (not new.is_tolling) then
			select sum(cost_with_tax) into invoice_cost from invoice_receipt_detail where owner_id = new.id;
			perform add_contractor_balance(new.id, new.entity_kind_id, new.doc_number, new.contractor_id, invoice_cost, new.receipt_date, 'income'::document_direction);
			perform send_notify_list('balance_contractor', new.contractor_id, 'refresh');
        end if;
	
		-- откорректируем остатки материалов с учётом поступивших
		for rgoods in
			select goods_id, amount, cost from invoice_receipt_detail where owner_id = new.id
		loop
			if (new.is_tolling) then
				perform goods_balance_receipt(new.id, new.entity_kind_id, new.doc_number, rgoods.goods_id, new.contractor_id, rgoods.amount, new.receipt_date);
			else
				perform goods_balance_receipt(new.id, new.entity_kind_id, new.doc_number, rgoods.goods_id, rgoods.amount, rgoods.cost, new.receipt_date);
			end if;
		
			perform send_notify_list('balance_goods', rgoods.goods_id, 'refresh');
		end loop;
	end if;

	-- КОРРЕКТЕН => МАТЕРИАЛ ПОЛУЧЕН
	if (old.status_id = 1001 and new.status_id = 3004) then
		-- скорректируем состояние заказа (если он есть)
		if (new.owner_id is not null) then
			select status_id into purchase_status from purchase_request where id = new.owner_id;
			if (purchase_status not in (1001, 3001, 3002)) then
				raise 'Заказ должен находится в состоянии КОРРЕКТЕН, ОТПРАВЛЕН или ПОЛУЧЕН СЧЁТ';
			end if;
		
			-- заказ переводим в состояние МАТЕРИАЛ ПОЛУЧЕН
			update purchase_request set status_id = 3004 where id = new.owner_id;
			perform send_notify_object('purchase_request', new.owner_id, 'refresh');
		end if;
	end if;

	-- КОРРЕКТЕН => МАТЕРИАЛ ПОЛУЧЕН И ОПЛАЧЕН
	if (old.status_id in (1001, 3004, 3006) and new.status_id = 3005) then
		-- скорректируем состояние заказа (если он есть)
		if (new.owner_id is not null) then
			select status_id into purchase_status from purchase_request where id = new.owner_id;
			if (purchase_status not in (3003, 3004, 3006)) then
				raise 'Заказ должен находится в состоянии МАТЕРИАЛ ПОЛУЧЕН, СЧЁТ ОПЛАЧЕН или ТРЕБУЕТСЯ ДОПЛАТА';
			end if;
		
			-- заказ переводим в состояние МАТЕРИАЛ ПОЛУЧЕН И ОПЛАЧЕН
			update purchase_request set status_id = 3005 where id = new.owner_id;
			perform send_notify_object('purchase_request', new.owner_id, 'refresh');
		end if;
	end if;

	-- КОРРЕКТЕН => ТРЕБУЕТСЯ ДОПЛАТА
	if (old.status_id in (1001, 3004) and new.status_id = 3006) then
		-- скорректируем состояние заказа (если он есть)
		if (new.owner_id is not null) then
			select status_id into purchase_status from purchase_request where id = new.owner_id;
			if (purchase_status not in (3003, 3004, 3006)) then
				raise 'Заказ должен находится в состоянии МАТЕРИАЛ ПОЛУЧЕН, СЧЁТ ОПЛАЧЕН или ТРЕБУЕТСЯ ДОПЛАТА';
			end if;
		
			if (purchase_status = 3003) then
				-- заказ переводим в состояние ТРЕБУЕТСЯ ДОПЛАТА
				update purchase_request set status_id = 3006 where id = new.owner_id;
				perform send_notify_object('purchase_request', new.owner_id, 'refresh');
			end if;
		end if;
	end if;

	-- МАТЕРИАЛ ПОЛУЧЕН, МАТЕРИАЛ ПОЛУЧЕН И ОПЛАЧЕН или ТРЕБУЕТСЯ ДОПЛАТА  => ОТМЕНЁН или ИЗМЕНЯЕТСЯ
	if (old.status_id in (3004, 3005, 3006) and new.status_id in (1004, 1011)) then
		-- уменьшим задолженность поставщику
		if (not new.is_tolling) then
			perform delete_balance_contractor(new.id);
			perform send_notify_list('balance_contractor', new.contractor_id, 'refresh');
		end if;
	
		-- откорректируем остатки материалов с учётом отмены поставки
		if (new.is_tolling) then
			perform delete_balance_tolling(new.id, new.contractor_id);
		else
			perform delete_balance_goods(new.id);
		end if;
	
		for rgoods in
			select goods_id from invoice_receipt_detail where owner_id = new.id
		loop
			perform send_notify_list('balance_goods', rgoods.goods_id, 'refresh');
		end loop;
	
		if (new.owner_id is not null) then
			select status_id into purchase_status from purchase_request where id = new.owner_id;
			if (purchase_status = 3000) then
				raise 'Заявка на приобретение материалов уже закрыта. Отменить платёжный документ не представляется возможным!';
			end if;
		
			-- если состояние заявки - МАТЕРИАЛ ПОЛУЧЕН И ОПЛАЧЕН, то вернём её в состояние СЧЁТ ОПЛАЧЕН,
			-- иначе определим предыдущее состояние заявки в которое и попытаемся её установить.
			if (purchase_status in (3005, 3006)) then
				purchase_status = 3003;
			else
				purchase_status = null;
				select from_status_id into purchase_status from history where reference_id = new.owner_id order by changed desc limit 1;
				if (purchase_status is null) then
					raise 'Обнаружено неопределенное предыдущее состояние заявки на расход! Необходимо вмешательство администратора';
				end if;
			end if;
		
			update purchase_request set status_id = purchase_status where id = new.owner_id;
			perform send_notify_object('purchase_request', new.owner_id, 'refresh');
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_invoice_receipt() OWNER TO postgres;

COMMENT ON FUNCTION public.changed_invoice_receipt() IS 'Поступление (акты / накладные) - ПРОВЕРКА ДАННЫХ';
