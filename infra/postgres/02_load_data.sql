\set ON_ERROR_STOP on

BEGIN;

TRUNCATE TABLE
    ecom.raw_items,
    ecom.raw_orders,
    ecom.raw_supplies,
    ecom.raw_products,
    ecom.raw_stores,
    ecom.raw_customers;

COPY ecom.raw_customers (id, name)
FROM '/tmp/jaffle-data/raw_customers.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY ecom.raw_stores (id, name, opened_at, tax_rate)
FROM '/tmp/jaffle-data/raw_stores.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY ecom.raw_products (sku, name, type, price, description)
FROM '/tmp/jaffle-data/raw_products.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY ecom.raw_supplies (id, name, cost, perishable, sku)
FROM '/tmp/jaffle-data/raw_supplies.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY ecom.raw_orders (id, customer_id, ordered_at, store_id, subtotal, tax_paid, order_total)
FROM '/tmp/jaffle-data/raw_orders.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY ecom.raw_items (id, order_id, sku)
FROM '/tmp/jaffle-data/raw_items.csv'
WITH (FORMAT CSV, HEADER TRUE);

COMMIT;