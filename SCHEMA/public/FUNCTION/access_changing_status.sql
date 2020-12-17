CREATE OR REPLACE FUNCTION public.access_changing_status(document_id uuid, changing_status_id uuid) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
begin
	return true;
end;
$$;

ALTER FUNCTION public.access_changing_status(document_id uuid, changing_status_id uuid) OWNER TO postgres;

COMMENT ON FUNCTION public.access_changing_status(document_id uuid, changing_status_id uuid) IS 'Процедура возвращает флаг видимости для функции перевода состояния указанного документа. Она вызывается из клиентского приложения в процедуре ContentEditor.CreateActionButtons при создании кнопок перевода состояния';
