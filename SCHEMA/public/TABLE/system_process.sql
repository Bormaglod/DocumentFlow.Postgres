CREATE TABLE public.system_process (
	id uuid NOT NULL,
	sysop public.system_operation NOT NULL,
	group_id bigint NOT NULL
);

ALTER TABLE public.system_process OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.system_process TO users;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.system_process TO managers;

--------------------------------------------------------------------------------

ALTER TABLE public.system_process
	ADD CONSTRAINT pk_system_process_id PRIMARY KEY (id);
