with days as (
    select cast(d as date) as date_day
    from range(date '2025-01-01', date '2026-12-31', interval 1 day) t(d)
)

select
    date_day,
    cast(strftime(date_day, '%Y%m%d') as integer) as date_key,
    year(date_day)                                as year,
    month(date_day)                               as month,
    strftime(date_day, '%B')                      as month_name,
    date_trunc('month', date_day)                 as month_start,
    isodow(date_day)                              as iso_day_of_week,
    isodow(date_day) >= 6                         as is_weekend,
    -- SA financial year for most of our clients runs March to February, like the tax year
    case when month(date_day) >= 3 then year(date_day) + 1 else year(date_day) end as financial_year
from days
