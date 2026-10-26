{#
  Source systems store money as integer cents. Convert once, in staging, and make sure the result is a DECIMAL:
  in DuckDB, dividing a decimal gives a DOUBLE, and summing doubles drifts by fractions of a cent.
#}
{% macro cents_to_rand(column) -%}
    cast(round({{ column }} / 100.0, 2) as decimal(18, 2))
{%- endmacro %}
