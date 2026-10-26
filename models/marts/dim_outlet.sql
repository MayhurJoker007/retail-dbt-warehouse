with first_last as (
    select outlet_id, min(order_date) as first_order_date, max(order_date) as last_order_date, count(*) as lifetime_orders
    from {{ ref('stg_orders') }}
    where status <> 'cancelled'
    group by outlet_id
)

select
    o.outlet_id,
    o.outlet_name,
    o.venue_type,
    o.region,
    o.country,
    o.created_on,
    f.first_order_date,
    f.last_order_date,
    coalesce(f.lifetime_orders, 0) as lifetime_orders,
    case
        when f.last_order_date is null then 'Never ordered'
        when f.last_order_date >= (select max(order_date) from {{ ref('stg_orders') }}) - interval 30 day then 'Active'
        when f.last_order_date >= (select max(order_date) from {{ ref('stg_orders') }}) - interval 90 day then 'Lapsing'
        else 'Lost'
    end as activity_status
from {{ ref('stg_outlets') }} o
left join first_last f using (outlet_id)
