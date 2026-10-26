select
    id                                            as order_id,
    outlet_id,
    distributor_id,
    cast(replace(placed_at, 'Z', '') as timestamp) as placed_at_utc,
    -- reports are read in South African time; a 23:30 UTC order belongs to the next day here
    cast(cast(replace(placed_at, 'Z', '') as timestamp) + interval 2 hour as date) as order_date,
    lower(trim(status))                            as status
from {{ ref('raw_orders') }}
