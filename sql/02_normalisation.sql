-- sql/02_normalisation.sql
CREATE SCHEMA IF NOT EXISTS bad;
SET search_path TO bad;

CREATE TABLE IF NOT EXISTS sales_record (
    sale_id BIGINT,
    sale_date DATE,
    customer_name VARCHAR(160),
    customer_email VARCHAR(255),
    customer_phones VARCHAR(255),
    customer_city VARCHAR(80),
    customer_country VARCHAR(60),
    product_name VARCHAR(120),
    product_category VARCHAR(60),
    product_price NUMERIC(10,2),
    quantity INT,
    line_total NUMERIC(10,2)
);

-- 1. 1NF VIOLATION:
--    Η στήλη customer_phones περιέχει πολλαπλές τιμές σε ένα πεδίο
--    π.χ. '555-1212, 555-3434'

-- 2. FUNCTIONAL DEPENDENCY 1 (παραβίαση 3NF):
--    product_name → product_category, product_price
--    Εξαρτώνται από το product_name, όχι από το sale_id

-- 3. FUNCTIONAL DEPENDENCY 2 (παραβίαση 3NF):
--    customer_email → customer_name, customer_city, customer_country
--    Εξαρτώνται από το email, όχι από το sale_id

-- 4. UPDATE ANOMALY:
--    Αν αλλάξει η τιμή ενός προϊόντος, πρέπει να ενημερωθούν
--    όλες οι γραμμές του προϊόντος — αν χάσουμε μία έχουμε inconsistent data

CREATE TABLE IF NOT EXISTS customer (
    customer_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(160) NOT NULL,
    city VARCHAR(80),
    country VARCHAR(60)
);

CREATE TABLE IF NOT EXISTS customer_phone (
    customer_id BIGINT NOT NULL REFERENCES customer ON DELETE CASCADE,
    phone VARCHAR(20) NOT NULL,
    PRIMARY KEY (customer_id, phone)
);

CREATE TABLE IF NOT EXISTS product (
    product_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(120) NOT NULL UNIQUE,
    category VARCHAR(60),
    unit_price NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE IF NOT EXISTS sale (
    sale_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customer ON DELETE RESTRICT,
    sale_date DATE NOT NULL
);

CREATE TABLE IF NOT EXISTS sale_item (
    sale_id BIGINT NOT NULL REFERENCES sale ON DELETE RESTRICT,
    product_id BIGINT NOT NULL REFERENCES product ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price_at_sale NUMERIC(10,2) NOT NULL CHECK (unit_price_at_sale >= 0),
    line_total NUMERIC(10,2) NOT NULL CHECK (line_total >= 0),
    PRIMARY KEY (sale_id, product_id)
);