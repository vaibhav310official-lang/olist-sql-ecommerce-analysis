/* =========================================================
   SECTION 2: CORE BUSINESS KPIs
   Objective: Measure overall company performance
   ========================================================= */
   -- Total revenue from delivered orders
SELECT 
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM order_items oi
JOIN orders o 
    ON oi.order_id = o.order_id
WHERE o.order_status = 'invoiced';

-- Average order value
SELECT 
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM order_items oi
JOIN orders o 
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

-- Average number of items per delivered order
SELECT 
    ROUND(COUNT(*) / COUNT(DISTINCT o.order_id), 2) AS avg_items_per_order
FROM order_items oi
JOIN orders o 
    ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered';

/* =========================================================
   SECTION 3: MONTHLY REVENUE TREND
   Objective: Analyze revenue performance over time
   ========================================================= */
   
   -- 3.1 Monthly revenue from delivered orders

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(oi.price), 2) AS monthly_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- 3.2 Monthly delivered order count

SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(*) AS monthly_orders
FROM orders
WHERE order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- 3.3 Monthly revenue and order volume together

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- 3.4 Monthly Average Order Value

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS monthly_aov
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

/* 3.5 Month-over-Month Revenue Growth
   Objective: Measure revenue growth percentage over time */

WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        SUM(oi.price) AS revenue
    FROM orders o
    JOIN order_items oi
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)
SELECT 
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month) AS previous_month_revenue,
    ROUND(
        ((revenue - LAG(revenue) OVER (ORDER BY order_month)) 
        / LAG(revenue) OVER (ORDER BY order_month)) * 100, 
    2) AS mom_growth_percentage
FROM monthly_revenue;
   
   /* =========================================================
   SECTION 4: CUSTOMER ANALYSIS
   Objective: Analyze customer behavior and repeat patterns
   ========================================================= */
 
 -- 4.1 Total unique customers who placed delivered orders
SELECT 
    COUNT(DISTINCT c.customer_unique_id) AS total_unique_customers
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered';

-- 4.2 Repeat customers (more than one delivered order)

SELECT 
    COUNT(*) AS repeat_customers
FROM (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
    HAVING COUNT(DISTINCT o.order_id) > 1
) AS repeat_data;

-- 4.3 Repeat customer rate (%)

WITH customer_orders AS (
    SELECT 
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT 
    COUNT(CASE WHEN total_orders > 1 THEN 1 END) AS repeat_customers,
    COUNT(*) AS total_customers,
    ROUND(
        COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0 / COUNT(*),
    2) AS repeat_customer_rate_percentage
FROM customer_orders;

  -- 4.4 REVENUE CONTRIBUTION by CUSTOMER TYPE (dynamic %)

WITH customer_type AS (
    SELECT 
        c.customer_unique_id,
        CASE 
            WHEN COUNT(DISTINCT o.order_id) > 1 THEN 'Repeat'
            ELSE 'One-Time'
        END AS customer_category
    FROM customers c
    JOIN orders o
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
),
revenue_data AS (
    SELECT 
        ct.customer_category,
        SUM(oi.price) AS revenue
    FROM customer_type ct
    JOIN customers c 
        ON ct.customer_unique_id = c.customer_unique_id
    JOIN orders o 
        ON c.customer_id = o.customer_id
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY ct.customer_category
)
SELECT 
    customer_category,
    ROUND(revenue, 2) AS total_revenue,
    ROUND(revenue * 100.0 / SUM(revenue) OVER(), 2) AS revenue_percentage
FROM revenue_data;
   
   
   
   
   
   
   
   
