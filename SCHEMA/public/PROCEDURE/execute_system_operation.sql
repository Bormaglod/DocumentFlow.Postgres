CREATE OR REPLACE PROCEDURE public.execute_system_operation(document_id uuid, sys_operation public.system_operation, value boolean, table_name character varying = NULL::character varying)
    LANGUAGE plpgsql
    AS $_$
declare
	field varchar;
	id_name varchar; 
	is_accepted bool;
	reaccept_needed bool;
	is_reaccept bool;
	gid bigint;
begin
	if (sys_operation = 'lock'::system_operation) then
		return;
	end if;

	-- если помечается на удаление или перепроводится бухгалтерский документ, то сначала отменим проведение
	if (sys_operation in ('accept'::system_operation, 'delete'::system_operation) and is_inherit_of(table_name, 'accounting_document') and value) then
		execute 'select carried_out, re_carried_out from ' || table_name || ' where id = $1'
			into is_accepted, reaccept_needed
			using document_id;
		if (is_accepted) then
			is_reaccept := true;
			if (sys_operation = 'accept'::system_operation) then
				if (exists(select * from pg_proc where proname = table_name || '_reaccept')) then
					execute 'select ' || table_name || '_reaccept($1)'
						into is_reaccept
						using document_id; 
				end if;
			end if;
		
			if (is_reaccept) then
				raise notice 'Отмена проведения % в связи с перепроведением', table_name;
				call execute_system_operation(document_id, 'accept', false, table_name);
			else
				if (reaccept_needed) then
					raise notice 'У документа % снят флаг re_carried_out', table_name;
					call set_system_value(document_id, 'lock_reaccept'::system_operation);
					execute 'update ' || table_name || ' set re_carried_out = false where id = $1'
						using document_id;
					call clear_system_value(document_id);
					return;
				end if;
			end if;
		end if;
	end if;

	gid = txid_current();
	raise notice 'execute_system_operation gid = %', gid;

	begin
		/*if (sys_operation = 'delete_childs'::system_operation) then
			if (table_name is null) then
				insert into system_process (id, sysop, group_id)
					select id, 'delete'::system_operation, gid from document_info where owner_id = document_id;
			else
				execute 'insert into system_process (id, sysop, group_id) select id, $1, $2 from ' || quote_ident(table_name) || ' where owner_id = $3'
					using 'delete'::system_operation, gid, document_id;
			end if;
		else*/
			insert into system_process (id, sysop, group_id) values (document_id, sys_operation, gid);
		--end if;
	exception
		when unique_violation then
			raise 'Кто-то уже обновляет эту запись (table name "%", id = %). Попробуйте выполнить действие ещё раз.', table_name, document_id;
	end;

	if (table_name is null) then
		case sys_operation
			when 'delete'::system_operation then
				update document_info set deleted = value where id = document_id;
			when 'delete_owned'::system_operation then
				update document_info set deleted = value where owner_id = document_id;
			when 'accept'::system_operation then
				update accounting_document set carried_out = value where id = document_id;
		end case;
	else
		if (sys_operation = 'accept'::system_operation) then 
			field = 'carried_out';
		else
			field = 'deleted';
		end if;
	
		if (sys_operation = 'delete_owned'::system_operation) then
			id_name = 'owner_id';
		else
			id_name = 'id';
		end if;
	
		execute 'update ' || quote_ident(table_name) || ' set ' || field || ' = $1 where ' || id_name || ' = $2'
			using value, document_id;
	end if;

	delete from system_process where group_id = gid;
end;
$_$;

ALTER PROCEDURE public.execute_system_operation(document_id uuid, sys_operation public.system_operation, value boolean, table_name character varying) OWNER TO postgres;
