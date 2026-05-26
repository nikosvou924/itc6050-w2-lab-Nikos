-- sql/04_indexing.sql
SET search_path TO shop;

-- ============================================================
-- 6a: BASELINE QUERIES (χωρίς indexes)
-- ============================================================

-- Q1: Look up a customer by email
EXPLAIN ANALYZE
SELECT *
FROM customer
WHERE email = 'cust5000@example.com';
-- Execution Time BEFORE: 0.322ms

-- Q2: All orders for a given customer in date order
EXPLAIN ANALYZE
SELECT order_id, order_date, total
FROM orders
WHERE customer_id = 5000
ORDER BY order_date DESC;
-- Execution Time BEFORE: 31.507ms

-- Q3: Top 10 products by revenue in the last 90 days
EXPLAIN ANALYZE
SELECT p.name,
    SUM(oi.quantity * oi.unit_price_at_sale) AS revenue
FROM order_item oi
JOIN orders o USING (order_id)
JOIN product p USING (product_id)
WHERE o.order_date >= NOW() - INTERVAL '90 days'
GROUP BY p.name
ORDER BY revenue DESC
LIMIT 10;
-- Execution Time BEFORE: 186.845ms

-- ============================================================
-- 6b: INDEXES
-- ============================================================

CREATE INDEX idx_customer_email ON customer (email);
CREATE INDEX idx_orders_customer_date ON orders (customer_id, order_date DESC);
CREATE INDEX idx_orders_date ON orders (order_date);
CREATE INDEX idx_order_item_order ON order_item (order_id);
CREATE INDEX idx_order_item_product ON order_item (product_id);

ANALYZE;

-- ============================================================
-- 6c: RE-RUN QUERIES AFTER INDEXES
-- ============================================================

-- Q1 AFTER: 0.152ms
-- Q2 AFTER: 1.433ms
-- Q3 AFTER: 127.432ms