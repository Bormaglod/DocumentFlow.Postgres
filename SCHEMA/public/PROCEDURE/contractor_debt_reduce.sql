CREATE OR REPLACE PROCEDURE public.contractor_debt_reduce(document_id uuid, doc_code character varying, doc_number integer, debt_date timestamp with time zone, contractor_id uuid, contract_id uuid, debt numeric)
    LANGUAGE plpgsql
    AS $$
begin
	call contractor_debt_change(document_id, doc_code, doc_number, debt_date, contractor_id, contract_id, debt, -1);
end;
$$;

ALTER PROCEDURE public.contractor_debt_reduce(document_id uuid, doc_code character varying, doc_number integer, debt_date timestamp with time zone, contractor_id uuid, contract_id uuid, debt numeric) OWNER TO postgres;

COMMENT ON PROCEDURE public.contractor_debt_reduce(document_id uuid, doc_code character varying, doc_number integer, debt_date timestamp with time zone, contractor_id uuid, contract_id uuid, debt numeric) IS 'Процедура уменьшает задолженность контрагента по указанному договору
- document_id - идентификатор документа добавляющего запись
- doc_code - вид документа
- doc_number - номер документа (может быть NULL)
- debt_date - дата появления задолженности (может быть NULL)
- contractor_id - идентификатор контрагента
- contract_id - идентификатор договора с контрагентом
- debt - сумма долга';
