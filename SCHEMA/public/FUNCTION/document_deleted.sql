CREATE OR REPLACE FUNCTION public.document_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
begin
	if (is_inherit_of(TG_TABLE_NAME::varchar, 'balance')) then
		return old;
	end if;

	if (old.deleted) then
		if (exists(select 1 from document_refs where owner_id = old.id)) then 
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, format('Запись (id = %L) содержит документы, информацию о которых необходимо удалить вручную.', old.id));
		end if;

		call send_notify(TG_TABLE_NAME::varchar, old.id, 'delete');
	
		-- если удаляемая запись содержится в таблице унаследованный от accounting_document то...
		-- проверим наличие остатков, которые мог сгенерировать этот документ
		if (is_inherit_of(TG_TABLE_NAME::varchar, 'accounting_document')) then
			-- если документ был проведен, отменим проведение
			if (new.carried_out) then
				execute 'update ' || TG_TABLE_NAME::varchar || ' set carried_out = false where id = $1'
					using old.id;
			end if;
		
			-- и на всякий случай удалим остатки, связанные с этим документом
			delete from balance where owner_id = old.id;
		end if;
	else
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, format('Запись (id = %L) не отмечена для удаления, поэтому ее невозможно удалить.', old.id));
	end if;

	return old;
end;
$_$;

ALTER FUNCTION public.document_deleted() OWNER TO postgres;
