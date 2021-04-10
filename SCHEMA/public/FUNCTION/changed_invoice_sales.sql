CREATE OR REPLACE FUNCTION public.changed_invoice_sales() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	invoice_cost numeric;
	rgoods record;
	order_status integer;
	duty numeric;
begin
	-- => УТВЕРДИТЬ
	if (new.status_id = 1002) then
		select sum(cost_with_tax) into invoice_cost from invoice_sales_detail where owner_id = new.id;
	
		perform add_contractor_balance(new.id, new.entity_kind_id, new.doc_number, new.contractor_id, invoice_cost, new.doc_date, 'expense'::document_direction);
		perform send_notify_list('balance_contractor', new.contractor_id, 'refresh');
	
		for rgoods in
			select goods_id, amount from invoice_sales_detail where owner_id = new.id
		loop
			perform goods_balance_expense(new.id, new.entity_kind_id, new.doc_number, rgoods.goods_id, rgoods.amount, new.doc_date);
			perform send_notify_list('balance_goods', rgoods.goods_id, 'refresh');
		end loop;
	
		-- ДЗСтп
		if (new.contractor_id = '5a5778be-f5ae-4761-a7c5-b64c13d88078') then
			select sum(amount * 2) from invoice_sales_detail isd
				into duty
				join goods g on (g.id = isd.goods_id)
				where isd.owner_id = new.id and not g.is_service;
	
			if (duty > 0) then
				-- Кравчук С.А.
				perform add_contractor_balance(new.id, new.entity_kind_id, new.doc_number, 'da28fcba-3199-4e92-8722-2424a9f1b4b2', duty, new.doc_date, 'income'::document_direction);
			end if;
		end if;
	end if;

	-- УТВЕРЖДЕН => ОТМЕНЕН или ИЗМЕНЯЕТСЯ
	if (old.status_id = 1002 and new.status_id in (1004, 1011)) then
		if (new.owner_id is not null) then
			select status_id into order_status from production_order where id = new.owner_id;
			if (order_status = 3000) then
				raise 'Заказ на изготовление уже закрыт. Отменить данный документ не представляется возможным!';
			end if;
		end if;
		
		perform delete_balance_contractor(new.id);
		perform send_notify_list('balance_contractor', new.contractor_id, 'refresh');
	
		perform delete_balance_goods(new.id);
		for rgoods in
			select goods_id from invoice_sales_detail where owner_id = new.id
		loop
			perform send_notify_list('balance_goods', rgoods.goods_id, 'refresh');
		end loop;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_invoice_sales() OWNER TO postgres;
