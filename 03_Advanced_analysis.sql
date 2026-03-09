/* =========================================================
   SECTION 5: PRODUCT & CATEGORY PERFORMANCE
   Objective: Identify top performing products and categories*/
   
   -- 5.1 Top product categories by revenue

SELECT
    p.product_category_name,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 5.2 Most sold product categories by quantity

SELECT
    p.product_category_name,
    COUNT(*) AS total_items_sold
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_items_sold DESC
LIMIT 10;

-- 5.3 Top products by revenue

SELECT
    oi.product_id,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id
ORDER BY total_revenue DESC
LIMIT 10;

-- 5.4 Most frequently purchased products

SELECT
    oi.product_id,
    COUNT(*) AS purchase_count
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY oi.product_id
ORDER BY purchase_count DESC
LIMIT 10;

-- 5.5 Average product price by category
-- This shows which categories are premium vs low-cost.--
SELECT
    p.product_category_name,
    ROUND(AVG(oi.price), 2) AS avg_product_price
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY avg_product_price DESC;

 /* 5.6 Category revenue share
   Objective: Measure contribution of each category
   ========================================================= */

SELECT
    p.product_category_name,
    ROUND(SUM(oi.price),2) AS total_revenue,
    ROUND(
        SUM(oi.price) * 100.0 /
        SUM(SUM(oi.price)) OVER(),
    2) AS revenue_percentage
FROM order_items oi
JOIN orders o
    ON oi.order_id = o.order_id
JOIN products p
    ON oi.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

/* =========================================================
   SECTION 6: GEOGRAPHIC SALES ANALYSIS
  6.1 Objective: Identify top performing regions*/

SELECT
    c.customer_state,
    ROUND(SUM(oi.price),2) AS total_revenue
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- 6.2 Top cities by delivered order count

SELECT
    c.customer_city,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_city
ORDER BY total_orders DESC
LIMIT 10;

-- 6.3 Revenue contribution by state

SELECT
    c.customer_state,
    ROUND(SUM(oi.price),2) AS total_revenue,
    ROUND(
        SUM(oi.price) * 100.0 /
        SUM(SUM(oi.price)) OVER(),
    2) AS revenue_percentage
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

/* =========================================================
   SECTION 7: DELIVERY PERFORMANCE ANALYSIS
   Objective: Evaluate shipping and delivery efficiency*/
   
   -- 7.1 Average delivery time in days

SELECT
    ROUND(
        AVG(DATEDIFF(o.order_delivered_customer_date, 
                     o.order_purchase_timestamp)),
    2) AS avg_delivery_days
FROM orders o
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL;

-- 7.2 Average delivery time by customer state

SELECT
    c.customer_state,
    ROUND(
        AVG(DATEDIFF(o.order_delivered_customer_date,
                     o.order_purchase_timestamp)),
    2) AS avg_delivery_days
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days DESC;

-- 7.3 Fastest delivery states

SELECT
    c.customer_state,
    ROUND(
        AVG(DATEDIFF(o.order_delivered_customer_date,
                     o.order_purchase_timestamp)),
    2) AS avg_delivery_days
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered'
AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days ASC
LIMIT 10;

-- Final Insights

-- Average revenue generated per customer

SELECT
ROUND(
    SUM(oi.price) / COUNT(DISTINCT c.customer_unique_id),
2) AS revenue_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered';

-- Average number of orders per customer

SELECT
ROUND(
    COUNT(DISTINCT o.order_id) /
    COUNT(DISTINCT c.customer_unique_id),
2) AS avg_orders_per_customer
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered';