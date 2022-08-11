CREATE OR REPLACE FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
declare
	amount_balances record;
begin
	select coalesce(sum(operation_summa * sign(amount)), 0) as operation_summa, coalesce(sum(amount), 0) as amount
    	into amount_balances
		from balance_product
		where
			reference_id = product_id and
			document_date < relevance_date;
		
	if (amount_balances.amount = 0) then
		return 0;
	else
		return round(amount_balances.operation_summa / amount_balances.amount, 2);
	end if;
end;
$$;

ALTER FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) OWNER TO postgres;

COMMENT ON FUNCTION public.average_price(product_id uuid, relevance_date timestamp with time zone) IS 'Возвращает среднюю цену материала на указанную дату
- product_id - идентификатор материала
- relevance_date - дата от которой ведется поиск остатков';
