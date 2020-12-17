CREATE VIEW public.consumption_view AS
	SELECT c.id,
    c.status_id,
    s.note AS status_name,
    ua.name AS user_created,
    p.name AS employee_name,
    c.doc_date,
    c.doc_number,
    c.organization_id,
    o.name AS organization_name
   FROM (((((public.consumption c
     JOIN public.status s ON ((s.id = c.status_id)))
     JOIN public.user_alias ua ON ((ua.id = c.user_created_id)))
     JOIN public.organization o ON ((o.id = c.organization_id)))
     LEFT JOIN public.employee e ON ((e.id = c.employee_id)))
     LEFT JOIN public.person p ON ((p.id = e.person_id)));

ALTER VIEW public.consumption_view OWNER TO postgres;

GRANT ALL ON TABLE public.consumption_view TO admins;
GRANT SELECT ON TABLE public.consumption_view TO users;
