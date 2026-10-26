-- Each line with the catalogue price that was valid on the order date, so the marts can flag lines that were
-- sold at a different price than the price list (manual overrides, stale app caches).
select
    l.order_id,
    l.product_id,
    o.order_date,
    o.outlet_id,
    o.distributor_id,
    o.status,
    l.quantity,
    l.unit_price,
    l.line_amount,
    p.price                                as list_price_on_date,
    l.unit_price <> coalesce(p.price, -1)  as is_off_list_price
from {{ ref('stg_order_lines') }} l
join {{ ref('stg_orders') }} o using (order_id)
left join {{ ref('stg_product_prices') }} p
    on p.product_id = l.product_id
   and o.order_date >= p.valid_from
   and o.order_date <  p.valid_to
