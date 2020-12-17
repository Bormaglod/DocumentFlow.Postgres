CREATE OR REPLACE FUNCTION public.send_notify_object(entity_name character varying, object_id uuid, action_name character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	perform pg_notify('db_notification', json_build_object('destination', 'Object', 'entity-id', get_uuid(entity_name), 'object-id', object_id, 'action', action_name)::text);
end
$$;

ALTER FUNCTION public.send_notify_object(entity_name character varying, object_id uuid, action_name character varying) OWNER TO postgres;

COMMENT ON FUNCTION public.send_notify_object(entity_name character varying, object_id uuid, action_name character varying) IS 'Отправояет сообщение о нобходимости обновления объекта:
- entity_name - наименование сущности из таблицы entity_kind
- object_id - идентификатор объекта
- action_name - наименование операции, которую необходимо выполнить
-- возможные значения: refresh, add, delete';
