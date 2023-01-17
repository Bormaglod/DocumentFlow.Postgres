CREATE OR REPLACE FUNCTION public.exception_text_builder(table_name name, tr_name name, exception_text character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $_$
declare 
	func_name varchar;
begin
	select substring(action_statement from '\s+(\S+)$') into func_name from information_schema.triggers where trigger_name = tr_name;
	return json_build_object('table', table_name, 'trigger', tr_name, 'function_name', func_name, 'text', exception_text)::text;
end;
$_$;

ALTER FUNCTION public.exception_text_builder(table_name name, tr_name name, exception_text character varying) OWNER TO postgres;
