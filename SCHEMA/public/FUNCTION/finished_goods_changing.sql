CREATE OR REPLACE FUNCTION public.finished_goods_changing() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	gid uuid;
begin
	if (new.owner_id is not null) then
		
		select 
			c.owner_id, c.cost_price
		into
			gid, new.price
		from production_lot pl
			join calculation c on (c.id = pl.calculation_id)
		where 
			pl.id = new.owner_id;
		
		if (new.carried_out) then
			if (new.goods_id is null) then
				new.goods_id = gid;
			else
				if (new.goods_id != gid) then
					raise 'В партии указано другое изделие!';
				end if;
			end if;
		end if;
	else
		if (new.goods_id is not null) then
			select 
				c.cost_price 
			into new.price 
			from goods g
				join calculation c on c.id = g.calculation_id
			where g.id = new.goods_id;
		end if;
	end if;

	if (new.price is not null) then
		new.product_cost := new.quantity * new.price;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.finished_goods_changing() OWNER TO postgres;
