CREATE TABLE public.wage_previous_periods (
	id bigint DEFAULT nextval('public.wage_previous_periods_id_seq'::regclass) NOT NULL,
	owner_id uuid,
	wage_year integer NOT NULL,
	wage_month smallint NOT NULL,
	wage numeric(15,2) NOT NULL
);

ALTER TABLE public.wage_previous_periods OWNER TO postgres;

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.wage_previous_periods TO payroll_accountant;

COMMENT ON TABLE public.wage_previous_periods IS 'Заработная плата предыдущих периодов';

COMMENT ON COLUMN public.wage_previous_periods.owner_id IS 'Начальный остаток к которому относятся предыдущие периоды';

COMMENT ON COLUMN public.wage_previous_periods.wage_year IS 'Год';

COMMENT ON COLUMN public.wage_previous_periods.wage_month IS 'Месяц';

COMMENT ON COLUMN public.wage_previous_periods.wage IS 'Заработная плата';

--------------------------------------------------------------------------------

ALTER TABLE public.wage_previous_periods
	ADD CONSTRAINT fk_wage_previous_periods_initial FOREIGN KEY (owner_id) REFERENCES public.initial_balance_employee(id) ON UPDATE CASCADE ON DELETE CASCADE;

--------------------------------------------------------------------------------

ALTER TABLE public.wage_previous_periods
	ADD CONSTRAINT pk_wage_previous_periods_id PRIMARY KEY (id);
