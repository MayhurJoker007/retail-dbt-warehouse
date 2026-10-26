select
    id            as distributor_id,
    name          as distributor_name,
    country_code,
    upper(erp)    as erp_system
from {{ ref('raw_distributors') }}
