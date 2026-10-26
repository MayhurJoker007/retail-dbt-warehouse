{#
  Generic test: the total of a column in this model equals the total in another model.
  Catches fan-out (a join that duplicates rows) and silent row loss between layers.
#}
{% test sums_match(model, column_name, compare_model, compare_column) %}
with a as (select coalesce(sum({{ column_name }}), 0) as total from {{ model }}),
     b as (select coalesce(sum({{ compare_column }}), 0) as total from {{ compare_model }})
select a.total as model_total, b.total as compare_total
from a, b
where abs(a.total - b.total) > 0.01
{% endtest %}
