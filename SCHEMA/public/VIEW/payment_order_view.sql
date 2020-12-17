CREATE VIEW public.payment_order_view AS
	SELECT po.id,
    po.status_id,
    s.note AS status_name,
    po.doc_date,
    po.doc_number,
    c.name AS contractor_name,
    po.date_debited,
        CASE po.direction
            WHEN 'expense'::public.document_direction THEN po.amount_debited
            ELSE NULL::money
        END AS expense,
        CASE po.direction
            WHEN 'income'::public.document_direction THEN po.amount_debited
            ELSE NULL::money
        END AS income,
    ua.name AS user_created,
    po.organization_id,
    org.name AS organization_name
   FROM ((((public.payment_order po
     JOIN public.status s ON ((s.id = po.status_id)))
     JOIN public.user_alias ua ON ((ua.id = po.user_created_id)))
     JOIN public.organization org ON ((org.id = po.organization_id)))
     LEFT JOIN public.contractor c ON ((c.id = po.contractor_id)));

ALTER VIEW public.payment_order_view OWNER TO postgres;

GRANT ALL ON TABLE public.payment_order_view TO admins;
GRANT SELECT ON TABLE public.payment_order_view TO users;
