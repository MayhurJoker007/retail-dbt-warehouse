select
    id                                   as product_id,
    distributor_id,
    upper(sku)                           as sku,
    name                                 as product_name,
    upper(left(category, 1)) || substr(category, 2) as category,
    {{ cents_to_rand('list_price_cents') }} as list_price
from {{ ref('raw_products') }}
