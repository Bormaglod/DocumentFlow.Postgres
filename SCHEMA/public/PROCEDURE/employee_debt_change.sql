CREATE OR REPLACE PROCEDURE public.employee_debt_change(document_id uuid, doc_code character varying, doc_number integer, debt_date timestamp with time zone, emp_id uuid, debt numeric, change_type integer)
    LANGUAGE plpgsql
    AS $_$
declare
	type_id uuid;
	init_date timestamptz;
begin
	if (doc_code is null) then
		raise 'Добавить запись в таблицу расчётов с сотрудниками невозможно [doc_code = NULL].';
	end if;

	select id into type_id from document_type where code = doc_code;
	if (type_id is null) then
		raise 'Добавить запись в таблицу расчётов с сотрудниками невозможно [таблица % не поддерживает запись остатков].', doc_code;
	end if;

	if (doc_number is null or debt_date is null) then
		execute 'select document_number, document_date from ' || doc_code || ' where id = $1'
			into doc_number, debt_date
			using document_id;
	end if;

	-- если документ добавляющий запись не "Начальный остаток"
	if (type_id != '9a543293-7a83-4f44-9344-38ad2698cc52') then
		select document_date into init_date from balance_employee where reference_id = emp_id and document_type_id = '9a543293-7a83-4f44-9344-38ad2698cc52';
		if (init_date is not null and init_date >= debt_date) then 
			raise 'Невозможно добавить запись, т.к. есть документ добавивший начальный остаток с более поздней датой';
		end if;
	end if;

	insert into balance_employee (owner_id, document_date, document_number, reference_id, operation_summa, amount, document_type_id)
		values (document_id, debt_date, doc_number, emp_id, debt, change_type, type_id);
	
	call send_notify('our_employee', emp_id, 'refresh');
	call send_notify('balance_employee', emp_id);
end;
$_$;

ALTER PROCEDURE public.employee_debt_change(document_id uuid, doc_code character varying, doc_number integer, debt_date timestamp with time zone, emp_id uuid, debt numeric, change_type integer) OWNER TO postgres;
