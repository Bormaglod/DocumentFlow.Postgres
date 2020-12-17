CREATE OR REPLACE FUNCTION public.changed_balance() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	perform rebuild_balance_goods(new.reference_id, new.document_date);

	return new;
end;
$$;

ALTER FUNCTION public.changed_balance() OWNER TO postgres;
