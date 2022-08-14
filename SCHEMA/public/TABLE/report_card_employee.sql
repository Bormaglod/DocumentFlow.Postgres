CREATE TABLE public.report_card_employee (
	id bigint DEFAULT nextval('public.report_card_employee_id_seq'::regclass) NOT NULL,
	owner_id uuid NOT NULL,
	employee_id uuid NOT NULL,
	labels character varying[],
	hours integer[]
);

ALTER TABLE public.report_card_employee OWNER TO postgres;

--------------------------------------------------------------------------------

ALTER TABLE public.report_card_employee
	ADD CONSTRAINT pk_report_card_employee_id PRIMARY KEY (id);

--------------------------------------------------------------------------------

ALTER TABLE public.report_card_employee
	ADD CONSTRAINT fk_report_card_employee_owner FOREIGN KEY (owner_id) REFERENCES public.report_card(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.report_card_employee
	ADD CONSTRAINT fk_report_card_employee_emp FOREIGN KEY (employee_id) REFERENCES public.our_employee(id) ON UPDATE CASCADE;
