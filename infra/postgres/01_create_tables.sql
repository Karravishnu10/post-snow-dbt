
CREATE SCHEMA IF NOT EXISTS ecom;

-- Automatically maintain updated_at whenever a row changes.
CREATE OR REPLACE FUNCTION ecom.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- 1. Customers
CREATE TABLE IF NOT EXISTS ecom.raw_customers (
    id           INTEGER PRIMARY KEY,
    name         VARCHAR(255),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 2. Orders
CREATE TABLE IF NOT EXISTS ecom.raw_orders (
    id           INTEGER PRIMARY KEY,
    customer_id  INTEGER,
    ordered_at   TIMESTAMPTZ,
    store_id     INTEGER,
    subtotal     INTEGER,
    tax_paid     INTEGER,
    order_total  INTEGER,
    status       VARCHAR(50),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 3. Products
CREATE TABLE IF NOT EXISTS ecom.raw_products (
    sku          VARCHAR(100) PRIMARY KEY,
    name         VARCHAR(255),
    type         VARCHAR(100),
    price        INTEGER,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 4. Stores
CREATE TABLE IF NOT EXISTS ecom.raw_stores (
    id           INTEGER PRIMARY KEY,
    name         VARCHAR(255),
    opened_at    TIMESTAMPTZ,
    tax_rate     NUMERIC(8,5),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 5. Order items
CREATE TABLE IF NOT EXISTS ecom.raw_items (
    id           INTEGER PRIMARY KEY,
    order_id     INTEGER,
    sku          VARCHAR(100),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 6. Supplies
CREATE TABLE IF NOT EXISTS ecom.raw_supplies (
    id           INTEGER PRIMARY KEY,
    name         VARCHAR(255),
    cost         INTEGER,
    perishable   BOOLEAN,
    sku          VARCHAR(100),
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Apply the updated_at trigger to all six tables.
DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOREACH table_name IN ARRAY ARRAY[
        'raw_customers',
        'raw_orders',
        'raw_products',
        'raw_stores',
        'raw_items',
        'raw_supplies'
    ]
    LOOP
        EXECUTE format(
            'DROP TRIGGER IF EXISTS trg_updated_at ON ecom.%I',
            table_name
        );

        EXECUTE format(
            'CREATE TRIGGER trg_updated_at
             BEFORE UPDATE ON ecom.%I
             FOR EACH ROW
             EXECUTE FUNCTION ecom.set_updated_at()',
            table_name
        );
    END LOOP;
END;
$$;
