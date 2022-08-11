CREATE OR REPLACE FUNCTION public.goods_updated() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (new.deleted) then
		update calculation set deleted = true where owner_id = new.id;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.goods_updated() OWNER TO postgres;
