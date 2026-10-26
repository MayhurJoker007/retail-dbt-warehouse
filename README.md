# Retail dbt warehouse

![dbt build](https://github.com/MayhurJoker007/retail-dbt-warehouse/actions/workflows/ci.yml/badge.svg)

A small dimensional warehouse for a B2B wholesale marketplace (distributors selling to spaza shops,
taverns and supermarkets in South Africa and Zambia), built with **dbt** on **DuckDB**, so it runs on a
laptop with nothing but `pip install`.

Most of my reporting work has been in SQL scripts, NiFi and Qlik load scripts. I built this to do the same
kind of modelling the dbt way: version-controlled transformations with tests that fail the build when the
numbers are wrong.

```
seeds (raw CSV, as exported)
  └─ staging      clean names and types, cents → rand, dedupe the export's duplicate lines, map free-text venue types
       └─ intermediate   attach the price that was valid on the order date
            └─ marts      fct_sales · dim_outlet · dim_product · dim_date · mart_distributor_monthly
```

## The raw data is deliberately messy

`scripts/generate_seeds.py` writes the seeds the way they actually arrive:

- money in **integer cents**
- order status in mixed case (`delivered`, `DELIVERED`)
- venue types typed by reps (`Spaza`, `Spaza `, `TAVERN`, `tavern`)
- about 1% of order lines **written twice** by an export that retried
- timestamps in **UTC**, while reports are read in SA time (UTC+2)
- a **price change** halfway through, stored as a price history table

## Tests

`dbt build` runs 48 models, seeds and tests. As well as the usual `unique`, `not_null`,
`relationships` and `accepted_values`, there are:

- **`assert_fct_sales_reconciles_to_staging`**: fact revenue must equal staged revenue for non-cancelled
  orders, *to the cent*. This one caught a real bug while I was building it. DuckDB returns a `DOUBLE` when you
  divide a `DECIMAL`, so the cents to rand conversion was producing floats, and the two totals differed by
  0.00000002. The `cents_to_rand` macro now casts the result back to `DECIMAL(18,2)`.
- `sums_match`, a reusable generic test that the monthly mart adds up to the fact table (it catches join fan-out).
- `unique_combination`, for grain checks on multi-column keys (no package needed).
- `assert_lines_sold_at_list_price`: every line matches the price list on its order date.
- `assert_no_overlapping_price_periods`.
- `assert_orders_belong_to_distributor_catalogue`: no Zambian order containing a South African distributor's product.

## The marts

**`fct_sales`**: one row per order line. Cancelled orders are excluded. Returns stay in with a negative net
amount, so revenue can be shown gross or net.

**`dim_outlet`**: first and last order, lifetime orders, and an activity status (Active / Lapsing / Lost /
Never ordered) relative to the latest data.

**`mart_distributor_monthly`**: what an account manager looks at: net revenue, returns, orders, buying
outlets, average order value and month-on-month change.

```
distributor          month     net_revenue  orders  outlets  avg_order  change
Highveld Beverages   2025-03    356 786.00     186      103   1 918.20
Highveld Beverages   2025-04    345 563.20     188       99   1 838.10    -3.1%
Highveld Beverages   2025-05    383 004.10     191      105   2 005.26   +10.8%
Highveld Beverages   2025-06    299 392.70     160       91   1 871.20   -21.8%
```

`dim_date` includes the March to February financial year that most SA businesses use.

## Running it

```
pip install -r requirements.txt
set DBT_PROFILES_DIR=.          (export DBT_PROFILES_DIR=. on Mac/Linux)
dbt build
dbt docs generate && dbt docs serve
```

The warehouse is written to `warehouse.duckdb`. To query it:

```
duckdb warehouse.duckdb "select * from marts.mart_distributor_monthly order by 1, 2"
```

`analyses/outlets_at_risk.sql` lists regular buyers who have gone quiet. To regenerate the seed data,
run `python scripts/generate_seeds.py`.
