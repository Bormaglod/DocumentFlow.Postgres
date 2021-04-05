CREATE OR REPLACE FUNCTION public.access_changing_status(document_id uuid, changing_status_id uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare
	debt record;
begin
	-- ПОСТУПЛЕНИЕ ТОВАРОВ/МАТЕРИАЛОВ
	
	-- Материал получен (КОРРЕКТЕН => МАТЕРИАЛ ПОЛУЧЕН)
	if (changing_status_id = '9687a7e2-6d68-4078-b6ee-37b0ec6bf983') then
    	select * from purchase_debt(document_id) into debt;
        return debt.no_payment;
    end if;
    
    -- Материал получен (КОРРЕКТЕН => МАТЕРИАЛ ПОЛУЧЕН И ОПЛАЧЕН)
    if (changing_status_id = 'c473f563-75b5-49b1-8038-5cc919499ac9') then
    	select * from purchase_debt(document_id) into debt;
        return not debt.no_payment and debt.debt_sum = 0;
    end if;
    
    -- Материал получен (КОРРЕКТЕН => ТРЕБУЕТСЯ ДОПЛАТА)
    if (changing_status_id = '3b8ebbff-d1a2-436c-bd87-dd716911ff4a') then
    	select * from purchase_debt(document_id) into debt;
        return not debt.no_payment and debt.debt_sum > 0;
    end if;
   
   -- Материал получен (МАТЕРИАЛ ПОЛУЧЕН => ЗАКРЫТ)
   if (changing_status_id = '1c4f49e5-b5de-42ef-8ee1-fdad86a8423c') then
    	return (select is_tolling from invoice_receipt ir where id = document_id); 
    end if;
    
	return true;
end;
$$;

ALTER FUNCTION public.access_changing_status(document_id uuid, changing_status_id uuid) OWNER TO postgres;

COMMENT ON FUNCTION public.access_changing_status(document_id uuid, changing_status_id uuid) IS 'Процедура возвращает флаг видимости для функции перевода состояния указанного документа. Она вызывается из клиентского приложения в процедуре ContentEditor.CreateActionButtons при создании кнопок перевода состояния';
