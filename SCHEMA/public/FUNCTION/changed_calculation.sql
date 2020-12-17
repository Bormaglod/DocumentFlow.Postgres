CREATE OR REPLACE FUNCTION public.changed_calculation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	kind_name varchar;
begin
	-- => КОРРЕКТЕН
	if (new.status_id = 1001) then
		select ek.name into kind_name from calc_item ci join entity_kind ek on (ek.id = ci.entity_kind_id) where ci.owner_id = new.id and new.status_id = 1000;
		if (kind_name is not null) then
			raise '% содержит запись в состоянии "Составлен", однако все записи должны быть в состоянии КОРРЕКТЕН', kind_name;
		end if;
	end if;

	-- => УТВЕРЖДЁН
	if (new.status_id = 1002) then
		if (exists (select * from calculation where owner_id = new.owner_id and status_id = 1002 and id != new.id)) then
			raise 'Уже есть утвержденная калькуляция. Что бы утвердить эту, предыдущую можно отправить в архив.';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.changed_calculation() OWNER TO postgres;
