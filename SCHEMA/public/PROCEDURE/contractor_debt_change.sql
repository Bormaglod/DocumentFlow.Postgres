CREATE OR REPLACE PROCEDURE public.contractor_debt_change(document_id uuid, doc_code character varying, doc_number integer, debt_date timestamp with time zone, contractor_id uuid, contract_id uuid, debt numeric, change_type integer)
    LANGUAGE plpgsql
    AS $_$
declare
	type_id uuid;
	init_date timestamptz;
begin
	if (doc_code is null) then
		raise 'Добавить запись в таблицу расчётов с контрагентами невозможно [doc_code = NULL].';
	end if;

	select id into type_id from document_type where code = doc_code;
	if (type_id is null) then
		raise 'Добавить запись в таблицу расчётов с контрагентами невозможно [таблица % не поддерживает запись остатков].', doc_code;
	end if;

	if (doc_number is null or debt_date is null) then
		execute 'select document_number, document_date from ' || doc_code || ' where id = $1'
			into doc_number, debt_date
			using document_id;
	end if;

	-- если документ добавляющий запись не "Начальный остаток"
	if (type_id != '363fcd46-a9dd-4da0-a1c4-0dfb8cc33e16') then
		select document_date into init_date from balance_contractor where reference_id = contractor_id and document_type_id = '363fcd46-a9dd-4da0-a1c4-0dfb8cc33e16';
		if (init_date is not null and init_date >= debt_date) then 
			raise 'Невозможно добавить запись, т.к. есть документ добавивший начальный остаток с более поздней датой';
		end if;
	end if;

	insert into balance_contractor (owner_id, document_date, document_number, reference_id, operation_summa, amount, document_type_id, contract_id)
		values (document_id, debt_date, doc_number, contractor_id, debt, change_type, type_id, contract_id);
	
	call send_notify('contractor', contractor_id, 'refresh');
	call send_notify('balance_contractor', contractor_id);
end;
$_$;

ALTER PROCEDURE public.contractor_debt_change(document_id uuid, doc_code character varying, doc_number integer, debt_date timestamp with time zone, contractor_id uuid, contract_id uuid, debt numeric, change_type integer) OWNER TO postgres;
