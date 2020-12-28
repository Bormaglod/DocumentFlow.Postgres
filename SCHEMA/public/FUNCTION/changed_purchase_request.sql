CREATE OR REPLACE FUNCTION public.changed_purchase_request() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	detail_count integer;
	goods_name varchar;
	invoice_count bigint;
	rec record;
begin
	-- СОСТАВЛЕН или ИЗМЕНЯЕТСЯ => КОРРЕКТЕН
	if (old.status_id in (1000, 1004) and new.status_id = 1001) then
		if (new.contractor_id is null) then
			raise 'Необходимо выбрать контрагента!';
		end if;
	
		if (new.contract_id is null) then
			raise 'Выберите договор с контрагентом';
		end if;
	
		select count(*) into detail_count from purchase_request_detail where owner_id = new.id;
		if (detail_count = 0) then
			raise 'Заявка не заполнена!';
		end if;
	
		if (exists(select * from purchase_request_detail where owner_id = new.id and goods_id is null)) then 
			raise 'Необходимо указать комплекующие которые подлежат заказу!';
		end if;
	
		select g.name into goods_name from purchase_request_detail prd join goods g on (prd.goods_id = g.id) where prd.amount = 0 and prd.owner_id = new.id;
		if (goods_name is not null) then
			raise 'Для "%" необходимо указать количество.', goods_name;
		end if;
	end if;

	-- МАТЕРИАЛ ПОЛУЧЕН И ОПЛАЧЕН => ЗАКРЫТ
	if (old.status_id = 3005 and new.status_id = 3000) then 
		select count(*) into invoice_count from invoice_receipt where owner_id = new.id and status_id != 3005;
		if (invoice_count > 0) then
			raise 'Что бы закрыть заявку, все документы на поступление товаров/материалов должны быть в состоянии МАТЕРИАЛ ПОЛУЧЕН И ОПЛАЧЕН.';
		end if;
	
		for rec in
			select ir.id from invoice_receipt ir where ir.owner_id = new.id
		loop 
			update invoice_receipt set status_id = 3000 where id = rec.id;
			perform send_notify_object('invoice_receipt', rec.id, 'refresh');
		end loop;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_purchase_request() OWNER TO postgres;

COMMENT ON FUNCTION public.changed_purchase_request() IS 'Заявка на приобретение материалов - ПРОВЕРКА ДАННЫХ';
