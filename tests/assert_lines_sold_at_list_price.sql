-- Every line should match the price list on the order date. Anything returned here was sold at a price
-- nobody approved, or the price history is missing a period.
select f.order_id, f.product_id, f.order_date, f.unit_price, p.list_price_on_date
from {{ ref('fct_sales') }} f
join {{ ref('int_order_lines_priced') }} p using (order_id, product_id)
where p.is_off_list_price
