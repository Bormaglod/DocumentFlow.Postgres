CREATE OR REPLACE PROCEDURE public.balance_product_receipt(document_id uuid, doc_code character varying, doc_number integer, receipt_date timestamp with time zone, prod public.price_data)
    LANGUAGE plpgsql
    AS $_$
declare
	balance_name varchar;
	type_id uuid;
	init_date timestamptz;
	init_id uuid;
begin
	balance_name := regexp_replace(prod.table_name, '^.*_', '');

	if (balance_name = 'goods') then
		if (select is_service from goods where id = prod.id) then
			return;
		end if;
	
		init_id = '64090dd1-b9f3-40f3-91de-f13c8c7a6ce2';
	else
		init_id = '286f9b29-d97b-4b59-ba8c-86513dc22839';
	end if;

	if (doc_code is null) then
		raise 'Добавить запись в таблицу остатков материалов невозможно [doc_code = NULL].';
	end if;

	select id into type_id from document_type where code = doc_code;
	if (type_id is null) then
		raise 'Добавить запись в таблицу остатков невозможно [таблица % не поддерживает запись остатков].', doc_code;
	end if;

	if (doc_number is null or receipt_date is null) then
		execute 'select document_number, document_date from ' || doc_code || ' where id = $1'
			into doc_number, receipt_date
			using document_id;
	end if;

	-- если документ добавляющий запись не "Начальный остаток"
	if (type_id != init_id) then
		execute 'select document_date from balance_' || balance_name || ' where reference_id = $1 and document_type_id = $2'
			into init_date
			using prod.id, init_id;
			
		if (init_date is not null and init_date >= receipt_date) then 
			raise 'Невозможно добавить запись, т.к. есть документ добавивший начальный остаток с более поздней датой';
		end if;
	end if;
	
	if (prod.product_cost != 0 or prod.amount != 0) then
		execute 'insert into balance_' || balance_name || ' (owner_id, document_date, document_number, reference_id, operation_summa, amount, document_type_id) values ($1, $2, $3, $4, $5, $6, $7)'
			using document_id, receipt_date, doc_number, prod.id, prod.product_cost, prod.amount, type_id;
	end if;
	
	call send_notify(balance_name, prod.id, 'refresh');
	call send_notify('balance_' || balance_name, prod.id);
end;
$_$;

ALTER PROCEDURE public.balance_product_receipt(document_id uuid, doc_code character varying, doc_number integer, receipt_date timestamp with time zone, prod public.price_data) OWNER TO postgres;

COMMENT ON PROCEDURE public.balance_product_receipt(document_id uuid, doc_code character varying, doc_number integer, receipt_date timestamp with time zone, prod public.price_data) IS 'Приход материала
- document_id - идентификатор документа по которому осуществляется поступление материала
- doc_code - вид документа
- doc_number - номер документа (может быть NULL)
- receipt_date - дата поступления (может быть NULL)
- prod - запись определяющая материал/товар/продукцию и его цену';
