
CREATE SCHEMA IF NOT EXISTS ecom;

CREATE OR REPLACE FUNCTION ecom.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;

-- These tables are still empty, so recreate them using source-compatible types.
DROP TABLE IF EXISTS
    ecom.raw_items,
    ecom.raw_orders,
    ecom.raw_supplies,
    ecom.raw_products,
    ecom.raw_stores,
    ecom.raw_customers
CASCADE;

CREATE TABLE ecom.raw_customers (
    id          UUID PRIMARY KEY,
    name        VARCHAR(255),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecom.raw_stores (
    id          UUID PRIMARY KEY,
    name        VARCHAR(255),
    opened_at   TIMESTAMPTZ,
    tax_rate    NUMERIC(8,5),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecom.raw_products (
    sku          VARCHAR(100) PRIMARY KEY,
    name         VARCHAR(255),
    type         VARCHAR(100),
    price        INTEGER,
    description  TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecom.raw_supplies (
    id          VARCHAR(100) PRIMARY KEY,
    name        VARCHAR(255),
    cost        INTEGER,
    perishable  BOOLEAN,
    sku         VARCHAR(100),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecom.raw_orders (
    id           UUID PRIMARY KEY,
    customer_id  UUID,
    ordered_at   TIMESTAMPTZ,
    store_id     UUID,
    subtotal     INTEGER,
    tax_paid     INTEGER,
    order_total  INTEGER,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ecom.raw_items (
    id          UUID PRIMARY KEY,
    order_id    UUID,
    sku         VARCHAR(100),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

DO $$
DECLARE
    t TEXT;
BEGIN
    FOREACH t IN ARRAY ARRAY[
        'raw_customers',
        'raw_stores',
        'raw_products',
        'raw_supplies',
        'raw_orders',
        'raw_items'
    ]
    LOOP
        EXECUTE format(
            'CREATE TRIGGER trg_updated_at
             BEFORE UPDATE ON ecom.%I
             FOR EACH ROW
             EXECUTE FUNCTION ecom.set_updated_at()',
            t
        );
    END LOOP;
END;
$$;
