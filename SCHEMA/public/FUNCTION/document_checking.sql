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
begin
	parent_table = get_info_table(TG_TABLE_NAME::varchar);
	if (parent_table is null) then
		raise 'Таблица % должна наследоватся либо от directory, либо от base_document', TG_TABLE_NAME;
	end if;

	if (is_inherit_of(TG_TABLE_NAME::varchar, 'accounting_document')) then
		if (new.carried_out != old.carried_out) then
			if (not exists(select * from system_process where id = new.id and sysop = 'accept'::system_operation)) then
				raise 'Провести (или отменить проведение) можно только с помощью процедуры execute_system_operation';
			end if;
		
			if (new.deleted and new.carried_out) then 
				raise 'Документ отмечен как удалённый. Провести его нельзя.';
			end if;
		end if;
	end if;

	if (parent_table = 'directory') then
		if (new.parent_id is not null) then
			select deleted, is_folder, item_name into parent_deleted, parent_folder, parent_name from directory where id = new.parent_id;
			if (not parent_folder) then
				raise 'Произведена попытка добавить запись в элемент справочника [%] не являющийся папкой', parent_name;
			end if;
		
			if (parent_deleted and TG_OP = 'INSERT') then
				raise 'Нельзя добавлять в удаленную папку.';
			end if;
		end if;
	
		if (TG_OP = 'UPDATE') then
			-- если снимаем отметку о том что элемент справочника - папка, то надо проверить,
			-- что бы отсутствовали подчиненные элементы
			if (new.is_folder != old.is_folder and not new.is_folder) then
				if (exists(select * from directory where parent_id = new.id)) then
					raise 'Элемент справочника % содержит подчиненные элементы, поэтому должен остаться папкой.', new.code;
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
			execute 'select id from ' || owner_table || ' where id = $1'
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
				if (parent_table = 'directory') then
					select id into owner_id_value from directory where id = new.owner_id;
				else
					select id into owner_id_value from accounting_document where id = new.owner_id;
				end if;
			else
				check_owner = false;
			end if;
		end if;
	
		if (owner_id_value is null and check_owner) then
			raise 'Владелец (id = %) не найден.', new.owner_id;
		end if;
	end if;

	return new;
end;
$_$;

ALTER FUNCTION public.document_checking() OWNER TO postgres;
