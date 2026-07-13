USE instacart_db;

-- ===============================
-- 1. Row Count Reconciliation
-- =============================== 
SELECT COUNT(*) FROM aisles;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM products;
SELECT COUNT(*) FROM departments;
SELECT COUNT(*) FROM order_products_prior;
SELECT COUNT(*) FROM order_products_train;

-- ============================================
-- 2. NULL Value Audit on Critical Columns
-- ============================================
SELECT
	COUNT(*) 
FROM orders 
WHERE order_id IS NULL;

SELECT
	COUNT(*)
FROM products
WHERE product_id IS NULL;

SELECT
	COUNT(*) 
FROM orders 
WHERE user_id IS NULL;

-- ========================
-- 3. Duplicate Detection
-- ========================
SELECT
	order_id,
    product_id,
    COUNT(*)
FROM order_products_prior
GROUP BY order_id, product_id;

-- ===============================================
-- 4. Referential Integrity Check (Orphan Records)
-- ===============================================
SELECT
	op.product_id
FROM order_products_prior op
LEFT JOIN products p
ON op.product_id=p.product_id
WHERE p.product_id IS NULL;

SELECT
	op.order_id
FROM order_products_prior op
LEFT JOIN orders o
ON op.order_id=o.order_id
WHERE o.order_id IS NULL;

-- =============================
-- 5. Range & Domain Validation
-- =============================
SELECT
	reordered
FROM order_products_prior
WHERE reordered NOT IN (1, 0);

SELECT
	reordered
FROM order_products_train
WHERE reordered NOT IN (1, 0);

SELECT
	add_to_cart_order
FROM order_products_prior
WHERE add_to_cart_order < 0;

SELECT
	add_to_cart_order
FROM order_products_train
WHERE add_to_cart_order < 0;

SELECT
	order_dow
FROM orders
WHERE order_dow > 6;

SELECT
	order_hour_of_day
FROM orders
WHERE order_hour_of_day > 23;


SELECT
	days_since_prior_order
FROM orders
WHERE days_since_prior_order < 0;

-- ===============================
-- 6. Distinct Count Sanity Check
-- ===============================
SELECT COUNT(DISTINCT aisle_id) FROM aisles;
SELECT COUNT(DISTINCT order_id) FROM orders;
SELECT COUNT(DISTINCT product_id) FROM products;
SELECT COUNT(DISTINCT department_id) FROM departments;
SELECT COUNT(DISTINCT order_id) FROM order_products_prior;
SELECT COUNT(DISTINCT order_id) FROM order_products_train;

-- ==========================
-- 7. Data Type Verification
-- ==========================
SHOW COLUMNS FROM aisles;
SHOW COLUMNS FROM orders;
SHOW COLUMNS FROM products;
SHOW COLUMNS FROM departments;
SHOW COLUMNS FROM order_products_prior;
SHOW COLUMNS FROM order_products_train;