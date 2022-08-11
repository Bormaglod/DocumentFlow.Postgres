CREATE OR REPLACE FUNCTION public.operation_deleted() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
	if (exists (select 1 from operations_performed where operation_id = new.id)) then 
		raise 'Эта операция используется в таблице "Выполненные работы". Её нельзя удалить.';
	end if;

	return old;
end;
$$;

ALTER FUNCTION public.operation_deleted() OWNER TO postgres;
