CREATE OR REPLACE PROCEDURE public.execute_system_operation(document_id uuid, sys_operation public.system_operation, value boolean, table_name character varying = NULL::character varying)
    LANGUAGE plpgsql
    AS $_$
declare
	field varchar;
	id_name varchar; 
	is_carried_out bool;
	gid bigint; 
begin
	if (sys_operation = 'lock'::system_operation) then
		return;
	end if;

	-- если помечается на удаление или перепроводится бухгалтерский документ, то сначала отменим проведение
	if (is_inherit_of(table_name, 'accounting_document') and value) then
		execute 'select carried_out from ' || table_name || ' where id = $1'
			into is_carried_out
			using document_id;
		if (is_carried_out) then
			call execute_system_operation(document_id, 'accept', false, table_name);
		end if;
	end if;

	gid = txid_current();

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
