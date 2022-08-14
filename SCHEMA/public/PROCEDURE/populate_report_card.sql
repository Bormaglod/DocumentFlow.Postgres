CREATE OR REPLACE PROCEDURE public.populate_report_card(report_card_id uuid)
    LANGUAGE plpgsql
    AS $$
declare
	emp record;
begin
	for emp in
		select id, income_items from our_employee
	loop
		if (array_position(emp.income_items, 'СДЛ') is not null) then
		
		end if;
	end loop;
end;
$$;

ALTER PROCEDURE public.populate_report_card(report_card_id uuid) OWNER TO postgres;
