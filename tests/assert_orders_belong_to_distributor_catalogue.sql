-- A Zambian distributor's order containing a South African distributor's product means the app or the
-- integration mixed up catalogues.
select f.order_id, f.product_id, f.distributor_id as order_distributor, p.distributor_id as product_distributor
from {{ ref('fct_sales') }} f
join {{ ref('stg_products') }} p using (product_id)
where f.distributor_id <> p.distributor_id
