/* ============================================================
   OLIST E-COMMERCE – END-TO-END ETL PIPELINE
   Output: dbo.fact_sales_final
   Period analyzed: Jan 2017 onward
============================================================ */


/* ============================================================
   1. REVIEW SOURCE TABLE STRUCTURES
============================================================ */

-- Inspect column names and data types
SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME IN (
    'olist_orders_dataset',
    'olist_customers_dataset',
    'olist_order_items_dataset',
    'olist_order_payments_dataset',
    'olist_products_dataset',
    'product_category_name_translation'
)
ORDER BY TABLE_NAME, ORDINAL_POSITION;


/* ============================================================
   2. DROP EXISTING TABLES (IDEMPOTENT EXECUTION)
============================================================ */

DROP TABLE IF EXISTS dbo.olist_order_items_clean;
DROP TABLE IF EXISTS dbo.olist_order_payments_clean;
DROP TABLE IF EXISTS dbo.fact_sales;
DROP TABLE IF EXISTS dbo.fact_sales_final;
GO


/* ============================================================
   3. CLEANING LAYER – MONETARY NORMALIZATION
============================================================ */

-- Convert price and freight from cents to currency units
SELECT
    order_id,
    order_item_id,
    product_id,
    seller_id,
    shipping_limit_date,
    price / 100.0         AS price,
    freight_value / 100.0 AS freight_value
INTO dbo.olist_order_items_clean
FROM dbo.olist_order_items_dataset;


-- Convert payment value from cents to currency units
SELECT
    order_id,
    payment_sequential,
    payment_type,
    payment_installments,
    payment_value / 100.0 AS payment_value
INTO dbo.olist_order_payments_clean
FROM dbo.olist_order_payments_dataset;


/* ============================================================
   4. CORE FACT TABLE – ITEM LEVEL GRAIN
============================================================ */

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
JOIN dbo.olist_order_payments_clean pay
    ON o.order_id = pay.order_id
    AND pay.payment_sequential = 1
WHERE o.order_status = 'delivered';


/* ============================================================
   5. DATA PROFILING – TEMPORAL COVERAGE
============================================================ */

-- Monthly distribution of orders and revenue
SELECT 
    YEAR(order_date)  AS year,
    MONTH(order_date) AS month,
    COUNT(*)          AS orders_count,
    SUM(total_value)  AS total_revenue
FROM dbo.fact_sales
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;


/* ============================================================
   6. DATA PROFILING – CATEGORY GAPS
============================================================ */

-- Identify missing categories
SELECT 
    COUNT(*) AS miss_categories
FROM dbo.fact_sales f
LEFT JOIN dbo.product_category_name_translation t
    ON f.product_category_name = t.product_category_name
WHERE t.product_category_name_english IS NULL;


/* ============================================================
   BUSINESS DECISION
   - November 2016 → 0 orders
   - December 2016 → 1 order
   - Analysis restricted to Jan 2017 onward
============================================================ */


/* ============================================================
   7. FINAL ANALYTICAL TABLE – BUSINESS LAYER
============================================================ */

SELECT
    f.order_id,
    f.order_date,
    f.customer_state,
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
    ON f.product_category_name = t.product_category_name
WHERE f.order_date >= '2017-01-01';


/* ============================================================
   8. FINAL VALIDATION
============================================================ */

-- Distinct products with unknown category (Dimension-level perspective)
SELECT 
    COUNT(DISTINCT product_id) AS unknown_distinct_products
FROM dbo.fact_sales_final
WHERE product_category = 'unknown';

-- Total sales records with unknown category (Fact-level perspective)
SELECT 
    COUNT(*) AS unknown_order_item_records
FROM dbo.fact_sales_final
WHERE product_category = 'unknown';

-- Revenue impact of unknown category (Business impact assessment)
SELECT 
    COUNT(*) AS unknown_order_item_records,
    SUM(total_value) AS unknown_total_revenue,
    AVG(total_value) AS avg_ticket_unknown
FROM dbo.fact_sales_final
WHERE product_category = 'unknown';

-- Confirm temporal continuity after filtering
SELECT 
    YEAR(order_date)  AS year,
    MONTH(order_date) AS month,
    COUNT(*)          AS orders_count,
    SUM(total_value)  AS total_revenue
FROM dbo.fact_sales_final
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

/* ============================================================
   OUTPUT TABLE:
   dbo.fact_sales_final
   Ready for Power BI
============================================================ */