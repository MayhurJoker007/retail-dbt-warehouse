"""Writes the raw CSVs in seeds/ the way they'd land from the source systems: amounts in cents, inconsistent
casing, a few duplicate order lines from a retried export, and timestamps in UTC.

    python scripts/generate_seeds.py
"""
import csv
import os
import random
from datetime import date, datetime, timedelta

rng = random.Random(7)
OUT = os.path.join(os.path.dirname(__file__), '..', 'seeds')

distributors = [
    (1, 'Highveld Beverages', 'ZA', 'sap'),
    (2, 'Copperbelt Foods', 'ZM', 'syspro'),
    (3, 'Coastal Snacks', 'ZA', 'syspro'),
]
products = [
    (101, 1, 'HB-COLA-330', 'Cola 330ml can (24)', 'soft drinks', 18990),
    (102, 1, 'HB-WATER-500', 'Still water 500ml (24)', 'soft drinks', 9600),
    (103, 1, 'HB-JUICE-1L', 'Orange juice 1L (12)', 'juice', 25450),
    (104, 1, 'HB-ENERGY-250', 'Energy drink 250ml (24)', 'soft drinks', 31200),
    (201, 2, 'CF-MEAL-10', 'Maize meal 10kg', 'staples', 21000),
    (202, 2, 'CF-OIL-2L', 'Cooking oil 2L (6)', 'staples', 39500),
    (203, 2, 'CF-SUGAR-2', 'Sugar 2kg (10)', 'staples', 28500),
    (301, 3, 'CS-CHIPS-125', 'Salted chips 125g (48)', 'snacks', 42000),
    (302, 3, 'CS-NUTS-50', 'Peanuts 50g (100)', 'snacks', 36500),
]
regions = ['Gauteng', 'KwaZulu-Natal', 'Western Cape', 'Limpopo', 'Lusaka', 'Copperbelt']
types = ['Spaza', 'TAVERN', 'tavern', 'Supermarket', 'liquor store', 'Spaza ']   # as captured: messy
names = ['Lucky', 'Ubuntu', 'Kasi', 'Mama Joy', 'Sizwe', 'Golden', 'Corner', 'Star', 'Royal', 'Naledi']

outlets = []
for i in range(1, 181):
    region = rng.choice(regions)
    outlets.append((i, '%s %s' % (rng.choice(names), rng.choice(['Store', 'Tavern', 'Shop', 'Liquors'])),
                    rng.choice(types), region, (date(2024, 1, 1) + timedelta(days=rng.randint(0, 500))).isoformat()))

orders, lines = [], []
order_id = 50000
start = datetime(2025, 3, 1)
for day in range(0, 240):
    for _ in range(rng.randint(8, 20)):
        order_id += 1
        outlet = rng.choice(outlets)
        dist = 2 if outlet[3] in ('Lusaka', 'Copperbelt') else rng.choice([1, 1, 3])
        placed = start + timedelta(days=day, hours=rng.randint(6, 18), minutes=rng.randint(0, 59))
        status = rng.choices(['delivered', 'delivered', 'delivered', 'cancelled', 'returned', 'open'], [60, 10, 10, 8, 4, 8])[0]
        orders.append((order_id, outlet[0], dist, placed.strftime('%Y-%m-%dT%H:%M:%SZ'), status.upper() if rng.random() < .1 else status))
        catalogue = [p for p in products if p[1] == dist]
        for p in rng.sample(catalogue, rng.randint(1, len(catalogue))):
            qty = rng.choice([1, 2, 2, 3, 5, 10])
            price = p[5] if placed < datetime(2025, 8, 1) else round(p[5] * 1.06)
            row = (order_id, p[0], qty, price)
            lines.append(row)
            if rng.random() < 0.01:
                lines.append(row)   # retried export wrote the line twice

prices = []
for p in products:
    prices.append((p[0], p[5], '2025-03-01', '2025-08-01'))
    prices.append((p[0], round(p[5] * 1.06), '2025-08-01', ''))

def write(name, header, rows):
    with open(os.path.join(OUT, name), 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)

write('raw_distributors.csv', ['id', 'name', 'country_code', 'erp'], distributors)
write('raw_products.csv', ['id', 'distributor_id', 'sku', 'name', 'category', 'list_price_cents'], products)
write('raw_product_prices.csv', ['product_id', 'price_cents', 'valid_from', 'valid_to'], prices)
write('raw_outlets.csv', ['id', 'name', 'venue_type', 'region', 'created_on'], outlets)
write('raw_orders.csv', ['id', 'outlet_id', 'distributor_id', 'placed_at', 'status'], orders)
write('raw_order_lines.csv', ['order_id', 'product_id', 'quantity', 'unit_price_cents'], lines)
print('%d orders, %d lines' % (len(orders), len(lines)))
