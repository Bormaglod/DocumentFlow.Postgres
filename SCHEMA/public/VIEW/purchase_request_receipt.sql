CREATE VIEW public.purchase_request_receipt AS
	SELECT purchase_request.id,
    purchase_request.owner_id,
    purchase_request.user_created_id,
    purchase_request.date_created,
    purchase_request.user_updated_id,
    purchase_request.date_updated,
    purchase_request.deleted,
    purchase_request.organization_id,
    purchase_request.document_date,
    purchase_request.document_number,
    purchase_request.carried_out,
    purchase_request.re_carried_out,
    purchase_request.contractor_id,
    purchase_request.contract_id,
    purchase_request.note,
    purchase_request.state,
    o.item_name AS organization_name,
    c.item_name AS contractor_name,
    contract.tax_payer,
        CASE contract.tax_payer
            WHEN true THEN 20
            ELSE 0
        END AS tax,
    contract.item_name AS contract_name,
    d.cost_order,
    d.tax_value,
    d.full_cost,
    p.transaction_amount AS prepayment,
    t.receipt_payment,
    ((COALESCE(w.full_cost, (0)::numeric) + COALESCE(debt.amount, (0)::numeric)) - COALESCE(credit.amount, (0)::numeric)) AS delivery_amount
   FROM (((((((((public.purchase_request
     JOIN public.organization o ON ((o.id = purchase_request.organization_id)))
     JOIN public.contractor c ON ((c.id = purchase_request.contractor_id)))
     LEFT JOIN public.contract ON ((contract.id = purchase_request.contract_id)))
     LEFT JOIN ( SELECT wr2.owner_id,
            sum(ppr.transaction_amount) AS receipt_payment
           FROM (public.posting_payments_receipt ppr
             JOIN public.waybill_receipt wr2 ON ((wr2.id = ppr.document_id)))
          WHERE (ppr.carried_out AND wr2.carried_out AND (wr2.owner_id IS NOT NULL))
          GROUP BY wr2.owner_id) t ON ((t.owner_id = purchase_request.id)))
     LEFT JOIN ( SELECT wr3.owner_id,
            sum(wrp.full_cost) AS full_cost
           FROM (public.waybill_receipt_price wrp
             JOIN public.waybill_receipt wr3 ON ((wr3.id = wrp.owner_id)))
          WHERE (wr3.carried_out AND (wr3.owner_id IS NOT NULL))
          GROUP BY wr3.owner_id) w ON ((w.owner_id = purchase_request.id)))
     LEFT JOIN ( SELECT purchase_request_price.owner_id,
            sum(purchase_request_price.product_cost) AS cost_order,
            sum(purchase_request_price.tax_value) AS tax_value,
            sum(purchase_request_price.full_cost) AS full_cost
           FROM public.purchase_request_price
          GROUP BY purchase_request_price.owner_id) d ON ((d.owner_id = purchase_request.id)))
     LEFT JOIN ( SELECT posting_payments_purchase.document_id,
            sum(posting_payments_purchase.transaction_amount) AS transaction_amount
           FROM public.posting_payments_purchase
          WHERE posting_payments_purchase.carried_out
          GROUP BY posting_payments_purchase.document_id) p ON ((p.document_id = purchase_request.id)))
     LEFT JOIN ( SELECT wr.owner_id,
            sum(da.transaction_amount) AS amount
           FROM (public.debt_adjustment da
             JOIN public.waybill_receipt wr ON ((wr.id = da.document_debt_id)))
          GROUP BY wr.owner_id) debt ON ((debt.owner_id = purchase_request.id)))
     LEFT JOIN ( SELECT wr.owner_id,
            sum(da.transaction_amount) AS amount
           FROM (public.debt_adjustment da
             JOIN public.waybill_receipt wr ON ((wr.id = da.document_credit_id)))
          GROUP BY wr.owner_id) credit ON ((credit.owner_id = purchase_request.id)));

ALTER VIEW public.purchase_request_receipt OWNER TO postgres;

GRANT SELECT ON TABLE public.purchase_request_receipt TO users;

COMMENT ON COLUMN public.purchase_request_receipt.cost_order IS 'Сумма заказа';

COMMENT ON COLUMN public.purchase_request_receipt.tax_value IS 'Сумма НДС';

COMMENT ON COLUMN public.purchase_request_receipt.full_cost IS 'Сумма заказа с НДС';

COMMENT ON COLUMN public.purchase_request_receipt.prepayment IS 'Предоплата';

COMMENT ON COLUMN public.purchase_request_receipt.receipt_payment IS 'Оплата по документу поставки';

COMMENT ON COLUMN public.purchase_request_receipt.delivery_amount IS 'Общая сумма материалов по документу поставки';
