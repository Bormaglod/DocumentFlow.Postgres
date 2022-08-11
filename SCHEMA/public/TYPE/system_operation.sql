CREATE TYPE public.system_operation AS ENUM (
	'accept',
	'delete',
	'delete_childs',
	'delete_owned',
	'delete_nested',
	'lock',
	'update'
);

ALTER TYPE public.system_operation OWNER TO postgres;
