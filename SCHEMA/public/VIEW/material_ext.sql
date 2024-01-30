CREATE VIEW public.material_ext AS
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
    material.doc_name,
        CASE
            WHEN material.is_folder THEN '-1'::integer
            WHEN ((mp.prices IS NULL) OR (cardinality(mp.prices) = 0)) THEN 1
            WHEN (array_position(mp.prices, material.price) IS NULL) THEN 2
            ELSE 0
        END AS price_status,
    (EXISTS ( SELECT 1
           FROM (public.calculation_material cm
             JOIN public.calculation c ON ((c.id = cm.owner_id)))
          WHERE ((cm.item_id = material.id) AND (c.state = 'approved'::public.calculation_state)))) AS material_using,
    mb.product_balance
   FROM ((public.material
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

ALTER VIEW public.material_ext OWNER TO postgres;
