CREATE TABLE public.email_log (
	id bigint DEFAULT nextval('public.email_log_id_seq'::regclass) NOT NULL,
	email_id bigint NOT NULL,
	date_time_sending timestamp(0) with time zone NOT NULL,
	to_address character varying NOT NULL,
	document_id uuid,
	contractor_id uuid
);

ALTER TABLE public.email_log OWNER TO postgres;

GRANT SELECT,INSERT ON TABLE public.email_log TO users;

COMMENT ON COLUMN public.email_log.contractor_id IS 'Контрагент - получатель письма';

--------------------------------------------------------------------------------

ALTER TABLE public.email_log
	ADD CONSTRAINT pk_email_log_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.email_log
	ADD CONSTRAINT fk_email_log_email FOREIGN KEY (email_id) REFERENCES public.email(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.email_log
	ADD CONSTRAINT fk_email_log_contractor FOREIGN KEY (contractor_id) REFERENCES public.contractor(id) ON UPDATE CASCADE ON DELETE CASCADE;
