CREATE OR REPLACE FUNCTION public.add_contractor_balance(document_id uuid, doc_kind uuid, doc_number character varying, ref_id uuid, amount numeric, debited timestamp with time zone, doc_direction public.document_direction) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	kind_name varchar;
	dir integer;
	balance_id uuid;
	r record;
begin
	if (doc_kind is null or doc_number is null) then
		select entity_kind_id, view_number into r from document where id = document_id;
		doc_kind = coalesce(doc_kind, r.entity_kind_id);
		doc_number = coalesce(doc_number, r.view_number);
	end if;

	select name into kind_name from entity_kind where id = doc_kind;
	dir = case doc_direction
		when 'income'::document_direction then 1
		when 'expense'::document_direction then -1
		else 0
	end;
    
	if (dir = 0) then
		raise 'Не установленное значение направления движения денежных средств';
	end if;
    
	insert into balance_contractor (owner_id, document_date, document_name, document_number, reference_id, operation_summa, document_kind)
		values (document_id, debited, kind_name, doc_number, ref_id, amount * dir, doc_kind) returning id into balance_id;
	update balance_contractor
    	set status_id = 1111
        where id = balance_id;
end;
$$;

ALTER FUNCTION public.add_contractor_balance(document_id uuid, doc_kind uuid, doc_number character varying, ref_id uuid, amount numeric, debited timestamp with time zone, doc_direction public.document_direction) OWNER TO postgres;

COMMENT ON FUNCTION public.add_contractor_balance(document_id uuid, doc_kind uuid, doc_number character varying, ref_id uuid, amount numeric, debited timestamp with time zone, doc_direction public.document_direction) IS 'Создает движение по задолженности контрагента
- document_id - идентификатор документа добавляющего запись
- doc_kind  - тип этого документа (идентификатор entity_kind) (может быть NULL)
- doc_number - номер документа (может быть NULL)
- ref_id - идентификатор контрагента
- debited - дата появления задолженности (дебиторской/кредиторской)
- doc_direction - тип задолженности
-- income - кредиторская задолженность (мы должны)
-- expense - дебиторская задолженность (нам должны)';
