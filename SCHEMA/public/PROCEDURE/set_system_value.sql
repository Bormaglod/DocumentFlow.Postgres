CREATE OR REPLACE PROCEDURE public.set_system_value(doc_id uuid, system_value public.system_operation)
    LANGUAGE plpgsql
    AS $$
begin
	raise notice 'SET SYSTEM VALUE document_id = %', doc_id;
	begin
		insert into system_process (id, sysop, group_id) values (doc_id, system_value, txid_current());
	exception
		when unique_violation then
			raise 'Кто-то уже обновляет эту запись. Попробуйте выполнить действие ещё раз.';
	end;
end;
$$;

ALTER PROCEDURE public.set_system_value(doc_id uuid, system_value public.system_operation) OWNER TO postgres;
