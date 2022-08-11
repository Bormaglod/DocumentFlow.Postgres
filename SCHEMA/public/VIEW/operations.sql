CREATE VIEW public.operations AS
	SELECT o.id,
    o.owner_id,
    o.user_created_id,
    o.date_created,
    o.user_updated_id,
    o.date_updated,
    o.deleted,
    o.code,
    o.item_name,
    o.parent_id,
    o.is_folder,
    o.produced,
    o.prod_time,
    o.production_rate,
    o.type_id,
    o.salary,
    o.manual_input,
    ot.item_name AS type_name,
    (EXISTS ( SELECT 1
           FROM (public.calculation_operation co
             JOIN public.calculation c ON ((c.id = co.owner_id)))
          WHERE ((co.item_id = o.id) AND (c.state = 'approved'::public.calculation_state)))) AS operation_using
   FROM (ONLY public.operation o
     LEFT JOIN public.operation_type ot ON ((ot.id = o.type_id)));

ALTER VIEW public.operations OWNER TO postgres;

GRANT SELECT ON TABLE public.operations TO users;
