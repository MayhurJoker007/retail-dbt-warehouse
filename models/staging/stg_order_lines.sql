-- The source export retries and sometimes writes the same line twice. An order never legitimately has the same
-- product on two lines (the app merges them), so keep one row per order and product.
with ranked as (
    select
        *,
        row_number() over (partition by order_id, product_id order by quantity desc) as copy_number
    from {{ ref('raw_order_lines') }}
)

select
    order_id,
    product_id,
    quantity,
    {{ cents_to_rand('unit_price_cents') }}              as unit_price,
    {{ cents_to_rand('unit_price_cents * quantity') }}   as line_amount
from ranked
where copy_number = 1
