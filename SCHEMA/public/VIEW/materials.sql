CREATE VIEW public.materials AS
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
    m.code AS cross_name,
        CASE
            WHEN ((mp.prices IS NULL) OR (cardinality(mp.prices) = 0)) THEN 1
            WHEN (array_position(mp.prices, material.price) IS NULL) THEN 2
            ELSE 0
        END AS price_status,
    (EXISTS ( SELECT 1
           FROM (public.calculation_material cm
             JOIN public.calculation c ON ((c.id = cm.owner_id)))
          WHERE ((cm.item_id = material.id) AND (c.state = 'approved'::public.calculation_state)))) AS material_using,
    mb.product_balance,
    (EXISTS ( SELECT 1
           FROM public.document_refs dr
          WHERE ((dr.owner_id = material.id) AND (dr.thumbnail IS NOT NULL)))) AS thumbnails,
    material.wire_id,
    w.item_name AS wire_name,
    ms.abbreviation AS measurement_name,
    material.material_kind
   FROM (((((public.material
     LEFT JOIN public.material m ON ((m.id = material.owner_id)))
     LEFT JOIN public.measurement ms ON ((ms.id = material.measurement_id)))
     LEFT JOIN public.wire w ON ((w.id = material.wire_id)))
     LEFT JOIN ( WITH contract_prices AS (
                 SELECT DISTINCT ON (c.id, pa.product_id) pa.product_id,
                    pa.price
                   FROM (((public.contractor
                     JOIN public.contract c ON ((c.owner_id = contractor.id)))
                     JOIN public.contract_application ca ON ((ca.owner_id = c.id)))
                     JOIN public.price_approval pa ON ((pa.owner_id = ca.id)))
                  WHERE ((CURRENT_DATE >= ca.date_start) AND ((ca.date_end IS NULL) OR (CURRENT_DATE <= ca.date_end)))
                  ORDER BY c.id, pa.product_id, ca.date_start DESC
                )
         SELECT contract_prices.product_id,
            array_agg(contract_prices.price) AS prices
           FROM contract_prices
          GROUP BY contract_prices.product_id) mp ON ((mp.product_id = material.id)))
     LEFT JOIN ( SELECT balance_material.reference_id,
            sum(balance_material.amount) AS product_balance
           FROM public.balance_material
          GROUP BY balance_material.reference_id) mb ON ((mb.reference_id = material.id)));

ALTER VIEW public.materials OWNER TO postgres;

GRANT SELECT ON TABLE public.materials TO users;
