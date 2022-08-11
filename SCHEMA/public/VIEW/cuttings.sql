CREATE VIEW public.cuttings AS
	SELECT cutting.id,
    cutting.owner_id,
    cutting.user_created_id,
    cutting.date_created,
    cutting.user_updated_id,
    cutting.date_updated,
    cutting.deleted,
    cutting.code,
    cutting.item_name,
    cutting.parent_id,
    cutting.is_folder,
    cutting.produced,
    cutting.prod_time,
    cutting.production_rate,
    cutting.type_id,
    cutting.salary,
    cutting.segment_length,
    cutting.left_cleaning,
    cutting.left_sweep,
    cutting.right_cleaning,
    cutting.right_sweep,
    cutting.program_number,
    cutting.manual_input,
    (EXISTS ( SELECT 1
           FROM (public.calculation_cutting cc
             JOIN public.calculation c ON ((c.id = cc.owner_id)))
          WHERE ((cc.item_id = cutting.id) AND (c.state = 'approved'::public.calculation_state)))) AS operation_using
   FROM public.cutting;

ALTER VIEW public.cuttings OWNER TO postgres;

GRANT SELECT ON TABLE public.cuttings TO users;
