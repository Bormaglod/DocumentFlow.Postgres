CREATE VIEW public.goods_view AS
	SELECT g.id,
    g.parent_id,
    g.status_id,
    s.note AS status_name,
    g.code,
    g.ext_article,
    g.name,
    m.abbreviation,
    g.price,
    g.tax,
    g.min_order,
    g.is_service,
    c.cost,
    c.profit_percent,
    c.profit_value,
    c.price AS calc_price,
    ( SELECT history.changed
           FROM public.history
          WHERE ((history.reference_id = c.id) AND (history.to_status_id = 1002))
          ORDER BY history.changed DESC
         LIMIT 1) AS approved
   FROM (((public.goods g
     JOIN public.status s ON ((s.id = g.status_id)))
     LEFT JOIN public.measurement m ON ((g.measurement_id = m.id)))
     LEFT JOIN public.calculation c ON (((c.owner_id = g.id) AND (c.status_id = 1002))));

ALTER VIEW public.goods_view OWNER TO postgres;

GRANT ALL ON TABLE public.goods_view TO admins;
GRANT SELECT ON TABLE public.goods_view TO users;
