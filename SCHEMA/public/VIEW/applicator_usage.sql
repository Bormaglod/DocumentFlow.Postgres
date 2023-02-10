CREATE VIEW public.applicator_usage AS
	SELECT e.id,
    ("substring"((e.item_name)::text, '.+\((.+)\)'::text))::character varying(255) AS item_name,
    e.commissioning,
    e.starting_hits,
    sum(op.quantity) AS quantity
   FROM ((public.equipment e
     JOIN public.calculation_operation co ON ((co.tools_id = e.id)))
     LEFT JOIN public.operations_performed op ON ((op.operation_id = co.id)))
  WHERE (((e.item_name)::text ~~ 'Апп%'::text) AND (COALESCE(e.starting_hits, op.quantity) IS NOT NULL))
  GROUP BY e.id
  ORDER BY e.item_name;

ALTER VIEW public.applicator_usage OWNER TO postgres;
