CREATE OR REPLACE FUNCTION public.changing_balance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	beginner uuid;
	min_date timestamptz;
begin
	-- => НАЧАЛЬНЫЙ ОСТАТОК
	if (new.status_id = 1110) then
		select id into beginner from balance where status_id = 1110 and reference_id = new.reference_id and entity_kind_id = new.entity_kind_id;
		if (beginner is not null) then
			raise 'Уже есть установленный начальный остаток.';
		end if;
	
		select min(document_date) into min_date from balance where status_id = 1111 and reference_id = new.reference_id and entity_kind_id = new.entity_kind_id;
		if (min_date is not null and min_date < new.document_date) then
			raise 'Дата начального остатка должна быть самой первой среди всех записей.';
		end if;
	
		new.owner_id = null;
		new.document_name = null;
		new.document_number = null;
	end if;

	-- => ТЕКУЩИЙ ОСТАТОК
	if (new.status_id in (1111, 1112)) then
		if (new.owner_id is null) then
			raise 'Не установлен документ, который изменяет текущий остаток.';
		end if;
	
		select ek.name, d.doc_date, d.doc_number
			into new.document_name, new.document_date, new.document_number
			from document d 
				join entity_kind ek on (d.entity_kind_id = ek.id)
		where 
			d.id = new.owner_id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changing_balance() OWNER TO postgres;
