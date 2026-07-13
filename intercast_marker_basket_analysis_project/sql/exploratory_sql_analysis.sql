USE instacart_db;

-- ===========================
-- 1. Volume & Scale Overview
-- ===========================
SELECT
	COUNT(*) AS total_orders
FROM orders;

SELECT
	COUNT(DISTINCT user_id) AS unique_users
FROM orders;

SELECT
	COUNT(*) AS total_order_products
FROM order_products_prior;

-- 2. Order Frequency Distribution per User
SELECT
	MIN(total_orders) AS minimum_orders,
    MAX(total_orders) AS maximum_orders,
    ROUND(AVG(total_orders), 2) AS avg_orders
FROM
(
	SELECT
		user_id,
		COUNT(order_id) AS total_orders
	FROM orders 
	GROUP BY user_id
) AS user_order_count;

-- ========================
-- 3. Basket Size Analysis
-- ========================
SELECT
	MAX(total_products) AS maximum_products,
    MIN(total_products) AS minimum_products,
    ROUND(AVG(total_products), 2) AS avg_products
FROM
(
	SELECT
		order_id,
		COUNT(product_id) AS total_products
	FROM order_products_prior
	GROUP BY order_id
) AS per_order_products;

-- ===============================
-- 4. Top-N Products by Frequency
-- ===============================
SELECT
	product_id,
    COUNT(*) AS total_orders
FROM order_products_prior
GROUP BY product_id
ORDER BY total_orders DESC
LIMIT 10;

-- =========================
-- 5. Reorder Rate Analysis
-- =========================
SELECT
	product_id,
    COUNT(*) AS total_orders,
    SUM(reordered) AS reorder_count,
    ROUND(SUM(reordered) * 100.0 / COUNT(*), 2) AS reorder_percentage
FROM order_products_prior
GROUP BY product_id
ORDER BY reorder_percentage DESC; 

-- ===========================================
-- 6. Time-based Patterns (Day of Week & Hour)
-- ===========================================
SELECT
	order_dow,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_dow
ORDER BY order_dow;

SELECT
	order_hour_of_day,
    COUNT(*) AS total_orders
FROM orders 
GROUP BY order_hour_of_day
ORDER BY order_hour_of_day;

-- ===========================================
-- 7. Days Since Prior Order — Purchase Cycle
-- ===========================================
SELECT
    days_since_prior_order,
    COUNT(*) AS order_count
FROM orders
WHERE days_since_prior_order IS NOT NULL
GROUP BY days_since_prior_order
ORDER BY days_since_prior_order;

-- ======================================
-- 8. Department/Aisle Level Aggregation
-- ======================================
SELECT
	d.department,
    COUNT(opr.order_id) AS total_orders
FROM order_products_prior opr
JOIN products p
    ON opr.product_id = p.product_id
JOIN departments d
    ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY total_orders DESC;
