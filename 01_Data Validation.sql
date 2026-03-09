CREATE DATABASE ecommerce_project;
USE ecommerce_project;

# Creating tables for data import table from
CREATE TABLE customers (
    customer_id VARCHAR(50),
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(50)
);

CREATE TABLE orders (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    order_status VARCHAR(50),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);
CREATE TABLE order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price DECIMAL(10,2),
    freight_value DECIMAL(10,2)
);

CREATE TABLE products (
    product_id VARCHAR(50),
    product_category_name VARCHAR(100),
    product_name_length INT,
    product_description_length INT,
    product_photos_qty INT,
    product_weight_g INT,
    product_length_cm INT,
    product_height_cm INT,
    product_width_cm INT
);
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;
select * from customers;
# importing the data

LOAD DATA LOCAL INFILE 'F:/Vaibhav Docs/SQL  Learning/SQL PRoj/olist_orders_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'F:/Vaibhav Docs/SQL  Learning/SQL PRoj/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

# Creating Indexes
SHOW INDEX FROM orders;

SELECT order_id, order_item_id, COUNT(*)
FROM order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

# creating primary keys
ALTER TABLE order_items
ADD PRIMARY KEY (order_id, order_item_id);

CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_items_productid ON order_items(product_id);
-- ------------------------------------------------------------------------------------
-- DATA CLEANING
SELECT * 
FROM orders # orders table
WHERE order_purchase_timestamp IS NULL
   OR order_approved_at IS NULL
   OR order_delivered_carrier_date IS NULL
   OR order_delivered_customer_date IS NULL
   OR order_estimated_delivery_date IS NULL;
   
   SELECT *
FROM order_items # for order items table
WHERE shipping_limit_date IS NULL 
   OR price IS NULL or trim(price)=''
   OR freight_value IS NULL or trim(freight_value)='';
   
   SELECT *
FROM products
WHERE product_category_name IS NULL OR TRIM(product_category_name) = ''
   OR product_name_length IS NULL
   OR product_description_length IS NULL
   OR product_photos_qty IS NULL
   OR product_weight_g IS NULL
   OR product_length_cm IS NULL
   OR product_height_cm IS NULL
   OR product_width_cm IS NULL;

SELECT *
FROM customers
WHERE customer_unique_id IS NULL OR TRIM(customer_unique_id) = ''
   OR customer_zip_code_prefix IS NULL OR TRIM(customer_zip_code_prefix) = ''
   OR customer_city IS NULL OR TRIM(customer_city) = ''
   OR customer_state IS NULL OR TRIM(customer_state) = '';

/* Handling missing product categories
--    610 rows had NULL category values
--    Updated to 'Unknown'
--    ================================ */
UPDATE products
SET product_category_name = 'Unknown'
WHERE product_category_name IS NULL;

/* =========================================================
   SECTION 1: DATA VALIDATION
   Objective: Understand data volume and structure
   ========================================================= */
use ecommerce_project;
-- 1.1 Total number of orders
SELECT COUNT(*) AS total_orders
FROM orders; -- Output 99441

-- 1.2 Total number of order items
SELECT COUNT(*) AS total_order_items
FROM order_items; -- Output 112650

-- 1.3 Total unique customers (real people)
SELECT COUNT(DISTINCT customer_unique_id) AS total_unique_customers
FROM customers;  -- 96096 customers

-- 1.4 Date range of orders
SELECT 
    MIN(order_purchase_timestamp) AS first_order_date,
    MAX(order_purchase_timestamp) AS last_order_date
FROM orders;   # 4th sep 2016 to 17th oct 2018

-- 1.5 Order status distribution
SELECT 
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;

