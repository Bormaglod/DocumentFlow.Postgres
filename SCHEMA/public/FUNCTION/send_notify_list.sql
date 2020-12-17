CREATE OR REPLACE FUNCTION public.send_notify_list(entity_name character varying, action_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	perform pg_notify('db_notification', json_build_object('destination', 'List', 'entity-id', get_uuid(entity_name), 'action', action_name)::text);
end;
$$;

ALTER FUNCTION public.send_notify_list(entity_name character varying, action_name character varying) OWNER TO postgres;

COMMENT ON FUNCTION public.send_notify_list(entity_name character varying, action_name character varying) IS 'Отправляет сообщение о необходимости обновления списка объеков:
- entity_name - наименование сущности из таблицы entity_kind
- action_name - наименование операции, которую необходимо выполнить
-- возможные значения: refresh, delete';

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.send_notify_list(entity_name character varying, owner_id uuid, action_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	perform pg_notify('db_notification', json_build_object('destination', 'List', 'entity-id', get_uuid(entity_name), 'object-id', owner_id, 'action', action_name)::text);
end;$$;

ALTER FUNCTION public.send_notify_list(entity_name character varying, owner_id uuid, action_name character varying) OWNER TO postgres;

COMMENT ON FUNCTION public.send_notify_list(entity_name character varying, owner_id uuid, action_name character varying) IS 'Отправляет сообщение о необходимости обновления списка объеков у которых есть указанный владелец:
- entity_name - наименование сущности из таблицы entity_kind
- owner_id - идентификатор владельца объектов
- action_name - наименование операции, которую необходимо выполнить
-- возможные значения: refresh, delete';
