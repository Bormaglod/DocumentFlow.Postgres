CREATE OR REPLACE FUNCTION public.document_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
declare
	parent_table varchar;
    parent_folder bool;
   	parent_name varchar;
	owner_id_value uuid;
	constraint_keys varchar;
	parent_deleted bool;
	owner_table varchar;
	check_owner boolean;
	schema_document record;
	states record;
begin
	parent_table = get_info_table(TG_TABLE_NAME::varchar);
	if (parent_table is null) then
		raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Таблица ' || TG_TABLE_NAME || ' должна наследоватся либо от directory, либо от base_document');
	end if;

	if (is_inherit_of(TG_TABLE_NAME::varchar, 'accounting_document')) then
		if (new.carried_out != old.carried_out) then
			if (not exists(select * from system_process where id = new.id and sysop = 'accept'::system_operation)) then
				raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Провести (или отменить проведение) можно только с помощью процедуры execute_system_operation');
			end if;
		
			if (new.deleted and new.carried_out) then
				raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Документ отмечен как удалённый. Провести его нельзя.');
			end if;
		end if;
	end if;

	if (parent_table = 'directory') then
		if (new.parent_id is not null) then
			execute format('select deleted, is_folder, item_name from %I where id = $1', TG_TABLE_NAME::varchar)
				into parent_deleted, parent_folder, parent_name
				using new.parent_id;
			if (not parent_folder) then
				raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Произведена попытка добавить запись в элемент справочника [' || parent_name || '] не являющийся папкой.');
			end if;
		
			if (parent_deleted and TG_OP = 'INSERT') then
				raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Нельзя добавлять в удаленную папку.');
			end if;
		end if;
	
		if (TG_OP = 'UPDATE') then
			-- если снимаем отметку о том что элемент справочника - папка, то надо проверить,
			-- что бы отсутствовали подчиненные элементы
			if (new.is_folder != old.is_folder and not new.is_folder) then
				if (exists(select * from directory where parent_id = new.id)) then
					raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Элемент справочника ' || new.code || ' содержит подчиненные элементы, поэтому должен остаться папкой.');
				end if;
			end if;
		end if;
	else
		-- перевод состояния из неопределенного в любое считаем нормальным
		if (old.state_id != 0 and new.state_id != 0 and old.state_id != new.state_id) then
			-- найдём схему состояний для изменяемого документа
			select
				ss.id as schema_id,
				ss.starting_id,
				dt.document_name
			into schema_document
			from schema_states ss
				join document_type dt on dt.id = ss.document_type_id
			where 
				dt.code = TG_TABLE_NAME::varchar;
			
			-- если схема найдена, то надо проверить правиильно ли сделан перевод состояния
			if (found) then
				-- ищем в таблице переходов состояния нужное соответствие
				select
					s_from.note as from_name,
					s_to.note as to_name
				into states
				from changing_state cs
					join state s_from on s_from.id = cs.from_state_id
					join state s_to on s_to.id = cs.to_state_id
				where 
					cs.schema_id = schema_document.schema_id and 
					cs.from_state_id = old.state_id and 
					cs.to_state_id = new.state_id;
			
				if (not found) then
					raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Переход документа "' || schema_document.document_name || '" из состояния "' || states.from_name || '" в состояние "' || states.to_name || '" невозможен.');
				end if;
			end if;
		end if;
	end if;

	-- поле owner_id не во всех таблицах имеет ссылочную целостность, поэтому
	-- надо проверить наличие записи с id = owner_id в таблице-хозяине
	if (not new.owner_id is null) then
		check_owner = true;
		if (is_inherit_of(TG_TABLE_NAME::varchar, 'balance')) then
			select code into owner_table from document_type where id = new.document_type_id;
			execute format('select id from %I where id = $1', owner_table)
				into owner_id_value
				using new.owner_id;
		else
			-- проверим наличие foreigen key для текущей таблицы, который содержит owner_id
			-- если такого ключа нет, то попробуем сделать выборку из directory или document
			with con 
			as
			(
				select c.oid, c.conrelid, c.confrelid, c.conname, c.contype, c.conkey::SMALLINT[], generate_subscripts(c.conkey, 1) as No 
					from pg_constraint c 
					where c.contype = 'f'
			),
			attrs 
			as
			(
				select string_agg(attr.attname, ', ' order by con.No) as r_constraint_key_names, reftbl.relname
					from con 
						join pg_class tbl on con.conrelid = tbl.oid
						join pg_attribute attr on attr.attrelid = tbl.oid and attr.attnum = con.conkey[con.No]
						join pg_namespace nsp ON tbl.relnamespace = nsp.oid 
						left join pg_class reftbl ON con.confrelid = reftbl.oid
					where
						nsp.nspname = 'public' and 
						tbl.relname = TG_TABLE_NAME 
					group by con.conname, con.contype, reftbl.relname
			)
			select r_constraint_key_names into constraint_keys from attrs where r_constraint_key_names = 'owner_id';

			if (constraint_keys is null) then
				execute format('select id from %I where id = $1', TG_TABLE_NAME::varchar)
					into owner_id_value
					using new.owner_id;
			else
				check_owner = false;
			end if;
		end if;
	
		if (owner_id_value is null and check_owner) then
			raise exception using message = exception_text_builder(TG_TABLE_NAME, TG_NAME, 'Владелец (id = ' || new.owner_id || ') не найден.');
		end if;
	end if;

	return new;
end;
$_$;

ALTER FUNCTION public.document_checking() OWNER TO postgres;
