CREATE VIEW public.materials_simple AS
	SELECT material.id,
    material.owner_id,
    material.user_created_id,
    material.date_created,
    material.user_updated_id,
    material.date_updated,
    material.deleted,
    material.code,
    material.item_name,
    material.parent_id,
    material.is_folder,
    material.price,
    material.vat,
    material.measurement_id,
    material.weight,
    material.min_order,
    material.ext_article,
    material.wire_id,
    material.material_kind,
    m.code AS cross_name,
    (EXISTS ( SELECT 1
           FROM public.document_refs dr
          WHERE ((dr.owner_id = material.id) AND (dr.thumbnail IS NOT NULL)))) AS thumbnails,
    w.item_name AS wire_name,
    ms.abbreviation AS measurement_name
   FROM (((public.material
     LEFT JOIN public.material m ON ((m.id = material.owner_id)))
     LEFT JOIN public.measurement ms ON ((ms.id = material.measurement_id)))
     LEFT JOIN public.wire w ON ((w.id = material.wire_id)));

ALTER VIEW public.materials_simple OWNER TO postgres;

GRANT SELECT ON TABLE public.materials_simple TO users;
