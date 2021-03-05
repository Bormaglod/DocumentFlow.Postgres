CREATE OR REPLACE FUNCTION public.balance_sheet_goods(date_from timestamp with time zone, date_to timestamp with time zone, include_service boolean = false) RETURNS TABLE(id uuid, name character varying, opening_balance numeric, income numeric, expense numeric, closing_balance numeric)
    LANGUAGE sql
    AS $$
with balance as
(
	select bg.reference_id as gds_id, sum(bg.amount) as goods_balance
		from balance_goods bg
			left join document doc on (doc.id = bg.owner_id)
		where
			(bg.status_id = 1110 and bg.document_date::date < date_from::date) or
			(doc.doc_date::date < date_from::date)
		group by bg.reference_id
		having sum(bg.amount * sign(bg.operation_summa)) != 0
),
moving_goods as
(
	select
		bg.reference_id as gds_id, 
		sum(iif(bg.amount > 0, bg.amount, 0::numeric)) as goods_income,
		sum(iif(bg.amount < 0, abs(bg.amount), 0::numeric)) as goods_expense
		from balance_goods bg
			left join document doc on (doc.id = bg.owner_id)
		where
			(bg.status_id = 1110 and bg.document_date::date between date_from::date and date_to::date) or
			(doc.doc_date::date between date_from::date and date_to::date)
		group by bg.reference_id
)
select 
	g.id, 
	g.name, 
	coalesce(ob.goods_balance, 0) as opening_balance, 
	coalesce(mg.goods_income, 0) as income, 
	coalesce(mg.goods_expense, 0) as expense, 
	coalesce(ob.goods_balance, 0) + coalesce(mg.goods_income, 0) - coalesce(mg.goods_expense, 0) as closing_balance
	from goods g
		left join moving_goods mg on (mg.gds_id = g.id)
		left join balance ob on (ob.gds_id = g.id)
	where
		g.status_id = 1002 and
		not (
			ob.goods_balance is null and 
			mg.goods_income is null and 
			mg.goods_expense is null
		) and
		g.is_service = include_service
$$;

ALTER FUNCTION public.balance_sheet_goods(date_from timestamp with time zone, date_to timestamp with time zone, include_service boolean) OWNER TO postgres;
