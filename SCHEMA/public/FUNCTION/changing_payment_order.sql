CREATE OR REPLACE FUNCTION public.changing_payment_order() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	new.direction = case new.status_id
		when 1200 then 'expense'::document_direction
		when 1201 then 'income'::document_direction
		else new.direction
	end;

	new.amount_debited = coalesce(new.amount_debited, 0::money);

	return new;
end;
$$;

ALTER FUNCTION public.changing_payment_order() OWNER TO postgres;
