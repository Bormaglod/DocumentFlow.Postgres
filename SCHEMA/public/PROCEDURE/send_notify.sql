CREATE OR REPLACE PROCEDURE public.send_notify(entity_name character varying)
    LANGUAGE plpgsql
    AS $$
begin
	perform pg_notify('db_notification', json_build_object('destination', 'list', 'entity-name', entity_name, 'action', 'refresh')::text);
end;
$$;

ALTER PROCEDURE public.send_notify(entity_name character varying) OWNER TO postgres;

COMMENT ON PROCEDURE public.send_notify(entity_name character varying) IS 'Отправляет сообщение о необходимости обновления списка объеков:
- entity_name - наименование таблицы';

--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE public.send_notify(entity_name character varying, owner_id uuid)
    LANGUAGE plpgsql
    AS $$
begin
	perform pg_notify('db_notification', json_build_object('destination', 'list', 'entity-name', entity_name, 'object-id', owner_id, 'action', 'refresh')::text);
end;
$$;

ALTER PROCEDURE public.send_notify(entity_name character varying, owner_id uuid) OWNER TO postgres;

COMMENT ON PROCEDURE public.send_notify(entity_name character varying, owner_id uuid) IS 'Отправляет сообщение о необходимости обновления списка объеков у которых есть указанный владелец:
- entity_name - наименование таблицы
- owner_id - идентификатор владельца объектов';

--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE public.send_notify(entity_name character varying, object_id uuid, action_name character varying)
    LANGUAGE plpgsql
    AS $$
begin
	perform pg_notify('db_notification', json_build_object('destination', 'object', 'entity-name', entity_name, 'object-id', object_id, 'action', action_name)::text);
end;
$$;

ALTER PROCEDURE public.send_notify(entity_name character varying, object_id uuid, action_name character varying) OWNER TO postgres;

COMMENT ON PROCEDURE public.send_notify(entity_name character varying, object_id uuid, action_name character varying) IS 'Отправояет сообщение о нобходимости обновления объекта:
- entity_name - наименование таблицы
- object_id - идентификатор объекта
- action_name - наименование операции, которую необходимо выполнить (возможные значения: refresh, add, delete)';
