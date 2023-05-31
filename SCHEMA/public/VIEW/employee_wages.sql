CREATE VIEW public.employee_wages AS
	WITH prev AS (
         SELECT gpe.employee_id,
            sum(gpe.wage) AS wage
           FROM (public.gross_payroll gp
             JOIN public.gross_payroll_employee gpe ON ((gpe.owner_id = gp.id)))
          WHERE ((((make_date(gp.billing_year, (gp.billing_month)::integer, 1) + '1 mon -1 days'::interval))::date < CURRENT_DATE) AND gp.carried_out)
          GROUP BY gpe.employee_id
        ), pay_prev AS (
         SELECT pe.employee_id,
            sum(pe.wage) AS wage
           FROM (((public.payroll p
             JOIN public.payroll_employee pe ON ((pe.owner_id = p.id)))
             JOIN public.payroll_payment pp ON ((pp.owner_id = p.id)))
             JOIN public.gross_payroll gp ON ((gp.id = p.owner_id)))
          WHERE ((((date_trunc('month'::text, p.document_date) + '1 mon -1 days'::interval))::date < CURRENT_DATE) AND p.carried_out)
          GROUP BY pe.employee_id
        ), cur AS (
         SELECT gpe.employee_id,
            sum(gpe.wage) AS wage
           FROM (public.gross_payroll gp
             JOIN public.gross_payroll_employee gpe ON ((gpe.owner_id = gp.id)))
          WHERE (((date_trunc('month'::text, now()))::date = make_date(gp.billing_year, (gp.billing_month)::integer, 1)) AND gp.carried_out)
          GROUP BY gpe.employee_id
        ), pay_cur AS (
         SELECT pe.employee_id,
            sum(pe.wage) AS wage
           FROM ((public.payroll p
             JOIN public.payroll_employee pe ON ((pe.owner_id = p.id)))
             JOIN public.payroll_payment pp ON ((pp.owner_id = p.id)))
          WHERE (((date_trunc('month'::text, now()))::date = date_trunc('month'::text, p.document_date)) AND p.carried_out)
          GROUP BY pe.employee_id
        )
 SELECT oe.id,
    oe.item_name AS employee_name,
    (prev.wage - COALESCE(pay_prev.wage, (0)::numeric)) AS begining_balance,
    cur.wage AS current_calc,
    pay_cur.wage AS current_pay,
    (((COALESCE(prev.wage, (0)::numeric) - COALESCE(pay_prev.wage, (0)::numeric)) + COALESCE(cur.wage, (0)::numeric)) - COALESCE(pay_cur.wage, (0)::numeric)) AS ending_balance
   FROM ((((public.our_employee oe
     LEFT JOIN prev ON ((prev.employee_id = oe.id)))
     LEFT JOIN pay_prev ON ((pay_prev.employee_id = oe.id)))
     LEFT JOIN cur ON ((cur.employee_id = oe.id)))
     LEFT JOIN pay_cur ON ((pay_cur.employee_id = oe.id)))
  WHERE (COALESCE(prev.wage, pay_prev.wage, cur.wage, pay_cur.wage) IS NOT NULL);

ALTER VIEW public.employee_wages OWNER TO postgres;

GRANT SELECT ON TABLE public.employee_wages TO users;
