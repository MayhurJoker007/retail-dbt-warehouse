{# Use the schema names from dbt_project.yml as-is (raw, staging, marts) instead of prefixing them with the target schema. #}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {{ custom_schema_name if custom_schema_name else target.schema }}
{%- endmacro %}
