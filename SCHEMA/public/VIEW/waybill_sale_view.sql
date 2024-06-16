CREATE VIEW public.waybill_sale_view AS
	WITH products AS (
         SELECT waybill_sale_price.owner_id,
            sum(waybill_sale_price.product_cost) AS product_cost,
            sum(waybill_sale_price.tax_value) AS tax_value,
            sum(waybill_sale_price.full_cost) AS full_cost
           FROM public.waybill_sale_price
          GROUP BY waybill_sale_price.owner_id
        ), postings AS (
         SELECT posting_payments_sale.document_id,
            sum(posting_payments_sale.transaction_amount) AS transaction_amount
           FROM public.posting_payments_sale
          WHERE posting_payments_sale.carried_out
          GROUP BY posting_payments_sale.document_id
        ), wbs AS (
         SELECT ws.id,
            ws.owner_id,
            ws.user_created_id,
            ws.date_created,
            ws.user_updated_id,
            ws.date_updated,
            ws.deleted,
            ws.organization_id,
            ws.document_date,
            ws.document_number,
            ws.carried_out,
            ws.re_carried_out,
            ws.contractor_id,
            ws.contract_id,
            ws.waybill_number,
            ws.waybill_date,
            ws.invoice_number,
            ws.invoice_date,
            ws.upd,
            ws.state_id,
            pr.product_cost,
            pr.tax_value,
            pr.full_cost,
            po.transaction_amount AS paid,
            ((ws.document_date)::date + (c.payment_period)::integer) AS payment_date
           FROM (((public.waybill_sale ws
             JOIN products pr ON ((pr.owner_id = ws.id)))
             LEFT JOIN postings po ON ((po.document_id = ws.id)))
             LEFT JOIN public.contract c ON ((c.id = ws.contract_id)))
        )
 SELECT wbs.id,
    wbs.owner_id,
    wbs.user_created_id,
    wbs.date_created,
    wbs.user_updated_id,
    wbs.date_updated,
    wbs.deleted,
    wbs.organization_id,
    wbs.document_date,
    wbs.document_number,
    wbs.carried_out,
    wbs.re_carried_out,
    wbs.contractor_id,
    wbs.contract_id,
    wbs.waybill_number,
    wbs.waybill_date,
    wbs.invoice_number,
    wbs.invoice_date,
    wbs.upd,
    wbs.state_id,
    wbs.product_cost,
    wbs.tax_value,
    wbs.full_cost,
    wbs.paid,
    wbs.payment_date
   FROM wbs;

ALTER VIEW public.waybill_sale_view OWNER TO postgres;
