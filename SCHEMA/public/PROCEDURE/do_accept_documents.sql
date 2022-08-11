CREATE OR REPLACE PROCEDURE public.do_accept_documents(document_name character varying, date_from timestamp with time zone, date_to timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
declare
	df timestamptz;
	dt timestamptz;
	doc_id uuid;
	cnt bigint;
begin
	document_name = coalesce(document_name, 'accounting_document');
	if (date_from is null or date_to is null) then
		execute 'select min(document_date), max(document_date) from ' || document_name
			into df, dt;
		
		date_from := coalesce(date_from, df);
		date_to := coalesce(date_to, dt);
	end if;

	cnt = 0;
	for doc_id in
		execute 'select id from ' || document_name || ' where document_date between $1 and $2'
			using date_from, date_to
	loop
		call execute_system_operation(doc_id, 'accept'::system_operation, true, document_name);
		cnt := cnt + 1;
	end loop;

	raise notice 'Выполнено перепроведение документов для таблиц(ы) %. Обработано % документов', document_name, cnt;
end;
$_$;

ALTER PROCEDURE public.do_accept_documents(document_name character varying, date_from timestamp with time zone, date_to timestamp with time zone) OWNER TO postgres;
