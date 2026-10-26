select
    p.product_id,
    p.sku,
    p.product_name,
    p.category,
    d.distributor_name,
    d.erp_system,
    cur.price as current_price
from {{ ref('stg_products') }} p
join {{ ref('stg_distributors') }} d using (distributor_id)
left join {{ ref('stg_product_prices') }} cur
    on cur.product_id = p.product_id and cur.valid_to = date '9999-12-31'
