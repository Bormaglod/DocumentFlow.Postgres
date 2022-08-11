CREATE OR REPLACE PROCEDURE public.lock_document(doc_id uuid)
    LANGUAGE plpgsql
    AS $$
begin
	raise notice 'LOCK document_id = %', doc_id;
	begin
		insert into system_process (id, sysop, group_id) values (doc_id, 'lock'::system_operation, txid_current());
	exception
		when unique_violation then
			raise 'Кто-то уже обновляет эту запись (id = %). Попробуйте выполнить действие ещё раз.', doc_id;
	end;
end;
$$;

ALTER PROCEDURE public.lock_document(doc_id uuid) OWNER TO postgres;
