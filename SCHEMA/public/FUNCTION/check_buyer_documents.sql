CREATE OR REPLACE FUNCTION public.check_buyer_documents() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare 
	ctype contractor_type;
begin
	if (new.contractor_id is not null) then
		if (not exists(select * from contract where owner_id = new.contractor_id and contractor_type = 'buyer'::contractor_type)) then 
			raise 'У контрагента % нет нужного договора!', (select name from contractor where id = new.contractor_id);
		end if;
	end if;

	if (new.contract_id is not null) then
		select contractor_type into ctype from contract where id = new.contract_id;
		if (ctype = 'seller'::contractor_type) then
			raise 'Договор должен быть с покупателем!';
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.check_buyer_documents() OWNER TO postgres;
