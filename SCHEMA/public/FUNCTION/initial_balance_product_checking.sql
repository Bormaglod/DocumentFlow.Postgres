CREATE OR REPLACE FUNCTION public.initial_balance_product_checking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
	start_date timestamptz;
begin
	if (new.carried_out != old.carried_out) then
		if (new.carried_out) then
			if (new.operation_summa = 0) then
				raise 'Сумма остатка не должна быть равна 0.';
			end if;
		
			if (new.amount = 0) then
				raise 'Количество остатка не должно быть равно 0.';
			end if;
		
			if (TG_TABLE_NAME = 'initial_balance_material') then
				if (exists(select * from balance_material where reference_id = new.reference_id and document_type_id = '286f9b29-d97b-4b59-ba8c-86513dc22839')) then
					raise 'По материалу % уже заведены остатки. Провести документ нельзя',
						(select item_name from material where id = new.reference_id);
				end if;
		
				select min(document_date) into start_date from balance_material where reference_id = new.reference_id;
			elsif (TG_TABLE_NAME = 'initial_balance_goods') then
				if (exists(select * from balance_goods where reference_id = new.reference_id and document_type_id = '64090dd1-b9f3-40f3-91de-f13c8c7a6ce2')) then
					raise 'По товару % уже заведены остатки. Провести документ нельзя',
						(select item_name from goods where id = new.reference_id);
				end if;
		
				select min(document_date) into start_date from balance_goods where reference_id = new.reference_id;
			end if;
		
			if (start_date is not null) then
				if (new.document_date >= start_date) then
					raise 'Дата начального остатка должна самой ранней';
				end if;
			end if;
		end if;
	end if;

	return new;
end;
$$;

ALTER FUNCTION public.initial_balance_product_checking() OWNER TO postgres;
