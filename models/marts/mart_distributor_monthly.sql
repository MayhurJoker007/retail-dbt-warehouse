-- What distributor account managers look at each month.
with monthly as (
    select
        p.distributor_name,
        d.month_start,
        sum(f.net_amount)                                         as net_revenue,
        sum(f.gross_amount) filter (where f.is_returned)          as returned_value,
        count(distinct f.order_id)                                as orders,
        count(distinct f.outlet_id)                               as buying_outlets,
        sum(f.quantity)                                           as units
    from {{ ref('fct_sales') }} f
    join {{ ref('dim_product') }} p using (product_id)
    join {{ ref('dim_date') }} d using (date_key)
    group by 1, 2
)

select
    *,
    round(net_revenue / nullif(orders, 0), 2)                     as avg_order_value,
    lag(net_revenue) over (partition by distributor_name order by month_start) as previous_month_revenue,
    round(100 * (net_revenue / nullif(lag(net_revenue) over (partition by distributor_name order by month_start), 0) - 1), 1)
                                                                  as revenue_change_pct
from monthly
