-- Revenue in the fact table must equal the staged order lines for non-cancelled orders, to the cent.
-- If a join in between fans out or drops rows, this is where it shows up.
with staged as (
    select sum(l.line_amount) as total
    from {{ ref('stg_order_lines') }} l
    join {{ ref('stg_orders') }} o using (order_id)
    where o.status <> 'cancelled'
),
fact as (
    select sum(gross_amount) as total from {{ ref('fct_sales') }}
)
select staged.total as staged_total, fact.total as fact_total
from staged, fact
where staged.total <> fact.total
