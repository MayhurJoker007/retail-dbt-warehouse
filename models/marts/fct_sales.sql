-- Grain: one row per order line. Cancelled orders are excluded; returns stay in with a flag and negative
-- net amount so revenue can be shown gross or net of returns.
select
    l.order_id,
    l.product_id,
    l.outlet_id,
    l.distributor_id,
    cast(strftime(l.order_date, '%Y%m%d') as integer) as date_key,
    l.order_date,
    l.status,
    l.quantity,
    l.unit_price,
    l.line_amount                                      as gross_amount,
    case when l.status = 'returned' then -l.line_amount else l.line_amount end as net_amount,
    l.status = 'returned'                              as is_returned,
    l.is_off_list_price
from {{ ref('int_order_lines_priced') }} l
where l.status <> 'cancelled'
