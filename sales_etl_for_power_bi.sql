-- =============================================
--  Review table structures
-- =============================================
SELECT TOP 5 * FROM dbo.olist_orders_dataset;
SELECT TOP 5 * FROM dbo.olist_customers_dataset;
SELECT TOP 5 * FROM dbo.olist_order_items_dataset;
SELECT TOP 5 * FROM dbo.olist_order_payments_dataset;
SELECT TOP 5 * FROM dbo.olist_products_dataset;
SELECT TOP 5 * FROM dbo.product_category_name_translation;

-- =============================================
--  Create intermediate cleaned tables
-- =============================================
-- Drop tables if they already exist (in case the script is executed multiple times)
DROP TABLE IF EXISTS dbo.olist_order_items_clean;
DROP TABLE IF EXISTS dbo.olist_order_payments_clean;
GO

-- Adjust prices and freight values
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price / 100.0 AS price,
    freight_value / 100.0 AS freight_value
INTO dbo.olist_order_items_clean
FROM dbo.olist_order_items_dataset;

-- Adjust payment values
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value / 100.0 AS payment_value
INTO dbo.olist_order_payments_clean
FROM dbo.olist_order_payments_dataset;

-- Review cleaned tables
SELECT TOP 5 * FROM dbo.olist_order_items_clean;
SELECT TOP 5 * FROM dbo.olist_order_payments_clean;

-- =============================================
--  Create main analytical table (fact_sales)
-- =============================================
DROP TABLE IF EXISTS dbo.fact_sales;
GO

SELECT
    o.order_id,
    CAST(o.order_purchase_timestamp AS DATE) AS order_date,
    c.customer_state,
    p.product_category_name,
    oi.product_id,
    oi.seller_id,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_value,
    pay.payment_type
INTO dbo.fact_sales
FROM dbo.olist_orders_dataset o
JOIN dbo.olist_order_items_clean oi
    ON o.order_id = oi.order_id
JOIN dbo.olist_customers_dataset c
    ON o.customer_id = c.customer_id
JOIN dbo.olist_products_dataset p
    ON oi.product_id = p.product_id
-- Join with payments table, keeping only the first payment record
JOIN dbo.olist_order_payments_clean pay
    ON o.order_id = pay.order_id
    AND pay.payment_sequential = 1
WHERE o.order_status = 'delivered';

-- Review analytical table
SELECT TOP 10 * FROM dbo.fact_sales;

-- Count missing values in each column
SELECT 
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_nulls,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS order_date_nulls,
    SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS customer_state_nulls,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS product_category_name_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS seller_id_nulls,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS freight_value_nulls,
    SUM(CASE WHEN total_value IS NULL THEN 1 ELSE 0 END) AS total_value_nulls,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS payment_type_nulls
FROM dbo.fact_sales;

-- =============================================
--  Create final table for Power BI with product categories in English
-- =============================================
DROP TABLE IF EXISTS dbo.fact_sales_final;
GO

SELECT
    f.order_id,
    f.order_date,
    f.customer_state,
    -- If no match exists in the translation table, 
    -- t.product_category_name_english remains NULL
    -- and COALESCE() replaces it with 'unknown'
    COALESCE(t.product_category_name_english, 'unknown') AS product_category,
    f.product_id,
    f.seller_id,
    f.price,
    f.freight_value,
    f.total_value,
    f.payment_type
INTO dbo.fact_sales_final
FROM dbo.fact_sales f
LEFT JOIN dbo.product_category_name_translation t
    ON f.product_category_name = t.product_category_name;

-- Review final table
SELECT TOP 10 * FROM dbo.fact_sales_final;

-- =============================================
--  Missing data and category summary
-- =============================================
SELECT 
    COUNT(*) AS unknown_categories_count
FROM dbo.fact_sales_final
WHERE product_category = 'unknown';

-- Order count by product category
SELECT 
    product_category,
    COUNT(*) AS orders_count
FROM dbo.fact_sales_final
GROUP BY product_category
ORDER BY orders_count DESC;

-- =============================================
--  dbo.fact_sales_final is now ready for analysis in Power BI
-- =============================================
