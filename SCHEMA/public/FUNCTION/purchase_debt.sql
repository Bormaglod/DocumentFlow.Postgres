CREATE OR REPLACE FUNCTION public.purchase_debt(document_id uuid, OUT debt_sum money, OUT no_payment boolean) RETURNS record
    LANGUAGE plpgsql
    AS $$
declare
	invoice_sum money;
    payment_sum money;
    purchase uuid;
    purchase_payment_sum money;
begin
	select sum(ird.cost_with_tax) 
		into invoice_sum 
		from invoice_receipt_detail ird 
			join invoice_receipt ir on (ir.id = ird.owner_id) 
		where ird.owner_id = document_id and ir.status_id in (3004, 3005, 3006);
	
    select sum(amount_debited) into payment_sum from payment_order where invoice_receipt_id = document_id and status_id = 1002;
    select owner_id into purchase from invoice_receipt where id = document_id;
    if (purchase is not null) then
    	select sum(amount_debited) into purchase_payment_sum from payment_order where purchase_id = purchase and status_id = 1002;
    end if;
        
    invoice_sum = coalesce(invoice_sum, 0::money);
    payment_sum = coalesce(payment_sum, 0::money) + coalesce(purchase_payment_sum, 0::money);
    
    no_payment = (payment_sum = 0::money);
    debt_sum = invoice_sum - payment_sum;
    return;
end;
$$;

ALTER FUNCTION public.purchase_debt(document_id uuid, OUT debt_sum money, OUT no_payment boolean) OWNER TO postgres;

COMMENT ON FUNCTION public.purchase_debt(document_id uuid, OUT debt_sum money, OUT no_payment boolean) IS 'Возвращает сумму задолженности контрагенту по поставленным товарам/материалам
- document_id - идентификатор документа (invoice_receipt)
- debt_sum - (ВОЗВРАЩАЕМОЕ ЗНАЧЕНИЕ) сумма задолженности
- no_payment - (ВОЗВРАЩАЕМОЕ ЗНАЧЕНИЕ) true, если отсутстуют платежи';
