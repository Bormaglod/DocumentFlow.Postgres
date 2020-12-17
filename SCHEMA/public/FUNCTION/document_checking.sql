CREATE OR REPLACE FUNCTION public.document_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	parent_table varchar;
    parent_status integer;
	user_id uuid;
	changing_id uuid;
	rec_kind record;
	owner uuid;
	constraint_keys varchar;
begin
	parent_table = get_root_parent(TG_TABLE_NAME::varchar);
	if (parent_table is null) then
		raise 'Таблица % должна наследоватся либо от directory, либо от document', TG_TABLE_NAME;
	end if;

	if (parent_table = 'directory') then
		select name, has_group into rec_kind from entity_kind where id = new.entity_kind_id;
		if (not rec_kind.has_group and new.status_id = 500) then 
			raise 'Таблица "%" не допускает создания групп/папок.', rec_kind.name;
		end if;
	
		if (not new.parent_id is null) then
			select status_id into parent_status from directory where id = new.parent_id;
			if (parent_status != 500) then
				raise 'Произведена попытка добавить запись в группу не являющуюся группой';
			end if;
		end if;
	end if;

	if (parent_table = 'document') then
		if (new.status_id = 500) then
			raise 'Неверное значение состояния документа. Оно не может быть "%"',
				(select note from status where id = new.status_id);
        end if;
	end if;

	select id into user_id from user_alias where pg_name = session_user;

	if (TG_OP = 'UPDATE') then
		if (new.user_locked_id is not null) and (new.user_locked_id != user_id) then
			raise 'Запись заблокирована пользователем % в %', 
				(select name from user_alias where id = new.user_locked_id), 
				new.date_locked;
		end if;
		
		-- проверим возможность пользователя менять состояние документа
		if (new.status_id != old.status_id) then
			select c.id 
				into changing_id 
				from entity_kind k
					join transition t on (k.transition_id = t.id)
					join changing_status c on (c.transition_id = t.id)
				where
					k.id = new.entity_kind_id and
					c.from_status_id = old.status_id and
					c.to_status_id = new.status_id;
                    
			if (changing_id is null) then
				raise 'Переход документа "%" из состояния "%" в состояние "%" невозможен.',
					(select name from entity_kind where id = new.entity_kind_id),
					(select note from status where id = old.status_id),
					(select note from status where id = new.status_id);
			end if;
		end if;
        
		if (new.entity_kind_id != old.entity_kind_id) then
			raise 'Тип документа менять нельзя.';
		end if;
	end if;

	-- поле owner не во всех таблицах имеет ссылочную целостность, поэтому
	-- надо проверить наличие записи с id = owner_id в таблице-хозяине
	if (not new.owner_id is null) then
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
				select id into owner from directory where id = new.owner_id;
			else
				select id into owner from document where id = new.owner_id;
			end if;
	
			if (owner is null) then
				raise 'Владелец (id = %) не найден.', new.owner_id;
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.document_checking() OWNER TO postgres;
