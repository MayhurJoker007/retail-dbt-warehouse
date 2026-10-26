select
    product_id,
    {{ cents_to_rand('price_cents') }}                   as price,
    cast(valid_from as date)                              as valid_from,
    coalesce(cast(nullif(cast(valid_to as varchar), '') as date), date '9999-12-31') as valid_to
from {{ ref('raw_product_prices') }}
