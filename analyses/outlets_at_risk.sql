-- Outlets that used to order every week and have gone quiet. Run with: dbt compile, then paste into DuckDB.
select o.outlet_name, o.region, o.venue_type, o.lifetime_orders, o.last_order_date,
       datediff('day', o.last_order_date, (select max(order_date) from {{ ref('fct_sales') }})) as days_since_last_order
from {{ ref('dim_outlet') }} o
where o.activity_status in ('Lapsing', 'Lost') and o.lifetime_orders >= 15
order by o.lifetime_orders desc
