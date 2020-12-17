CREATE OR REPLACE FUNCTION public.goods_rest_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (TG_OP = 'INSERT' or new.owner_id != old.owner_id) then
		select e.name, d.doc_date, d.view_number
			into new.name, new.date_balance_changed, new.code
			from document d 
				join entity_kind e on (d.entity_kind_id = e.id) 
		where 
			d.id = new.owner_id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.goods_rest_update() OWNER TO postgres;
