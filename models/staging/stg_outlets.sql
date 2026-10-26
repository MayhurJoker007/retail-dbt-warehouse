select
    id                                as outlet_id,
    trim(name)                        as outlet_name,
    -- free text from the field app mapped to a fixed list
    case lower(trim(venue_type))
        when 'spaza'         then 'Spaza'
        when 'tavern'        then 'Tavern'
        when 'liquor store'  then 'Liquor store'
        when 'supermarket'   then 'Supermarket'
        else 'Other'
    end                               as venue_type,
    region,
    case when region in ('Lusaka', 'Copperbelt') then 'Zambia' else 'South Africa' end as country,
    cast(created_on as date)          as created_on
from {{ ref('raw_outlets') }}
