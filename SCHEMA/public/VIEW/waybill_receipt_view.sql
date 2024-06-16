CREATE VIEW public.waybill_receipt_view AS
	WITH wrp AS (
         SELECT waybill_receipt_price.owner_id,
            sum(waybill_receipt_price.product_cost) AS product_cost,
            sum(waybill_receipt_price.tax_value) AS tax_value,
            sum(waybill_receipt_price.full_cost) AS full_cost
           FROM public.waybill_receipt_price
          GROUP BY waybill_receipt_price.owner_id
        ), receipt AS (
         SELECT posting_payments_receipt.document_id,
            sum(posting_payments_receipt.transaction_amount) AS transaction_amount
           FROM public.posting_payments_receipt
          WHERE (posting_payments_receipt.carried_out = true)
          GROUP BY posting_payments_receipt.document_id
        ), purchase AS (
         SELECT posting_payments_purchase.document_id,
            sum(posting_payments_purchase.transaction_amount) AS transaction_amount
           FROM public.posting_payments_purchase
          WHERE (posting_payments_purchase.carried_out = true)
          GROUP BY posting_payments_purchase.document_id
        ), debt AS (
         SELECT debt_adjustment.document_debt_id,
            sum(debt_adjustment.transaction_amount) AS transaction_amount
           FROM public.debt_adjustment
          WHERE (debt_adjustment.carried_out = true)
          GROUP BY debt_adjustment.document_debt_id
        ), credit AS (
         SELECT debt_adjustment.document_credit_id,
            sum(debt_adjustment.transaction_amount) AS transaction_amount
           FROM public.debt_adjustment
          WHERE (debt_adjustment.carried_out = true)
          GROUP BY debt_adjustment.document_credit_id
        ), wbr AS (
         SELECT wr.id,
            wr.owner_id,
            wr.user_created_id,
            wr.date_created,
            wr.user_updated_id,
            wr.date_updated,
            wr.deleted,
            wr.organization_id,
            wr.document_date,
            wr.document_number,
            wr.carried_out,
            wr.re_carried_out,
            wr.contractor_id,
            wr.contract_id,
            wr.waybill_number,
            wr.waybill_date,
            wr.invoice_number,
            wr.invoice_date,
            wr.upd,
            wr.state_id,
            d.product_cost,
            d.tax_value,
            d.full_cost,
            (((COALESCE(ppr.transaction_amount, (0)::numeric) + COALESCE(ppp.transaction_amount, (0)::numeric)) + COALESCE(crdt.transaction_amount, (0)::numeric)) - COALESCE(dbt.transaction_amount, (0)::numeric)) AS paid,
            pr.document_number AS purchase_request_number,
            pr.document_date AS purchase_request_date
           FROM ((((((public.waybill_receipt wr
             LEFT JOIN public.purchase_request pr ON ((pr.id = wr.owner_id)))
             LEFT JOIN wrp d ON ((d.owner_id = wr.id)))
             LEFT JOIN receipt ppr ON ((ppr.document_id = wr.id)))
             LEFT JOIN purchase ppp ON ((ppp.document_id = pr.id)))
             LEFT JOIN debt dbt ON ((dbt.document_debt_id = wr.id)))
             LEFT JOIN credit crdt ON ((crdt.document_credit_id = wr.id)))
        )
 SELECT wbr.id,
    wbr.owner_id,
    wbr.user_created_id,
    wbr.date_created,
    wbr.user_updated_id,
    wbr.date_updated,
    wbr.deleted,
    wbr.organization_id,
    wbr.document_date,
    wbr.document_number,
    wbr.carried_out,
    wbr.re_carried_out,
    wbr.contractor_id,
    wbr.contract_id,
    wbr.waybill_number,
    wbr.waybill_date,
    wbr.invoice_number,
    wbr.invoice_date,
    wbr.upd,
    wbr.state_id,
    wbr.product_cost,
    wbr.tax_value,
    wbr.full_cost,
    wbr.paid,
    wbr.purchase_request_number,
    wbr.purchase_request_date
   FROM wbr;

ALTER VIEW public.waybill_receipt_view OWNER TO postgres;
