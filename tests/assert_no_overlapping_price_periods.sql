select a.product_id, a.valid_from, b.valid_from as overlapping_from
from {{ ref('stg_product_prices') }} a
join {{ ref('stg_product_prices') }} b
  on a.product_id = b.product_id
 and a.valid_from < b.valid_from
 and a.valid_to > b.valid_from
