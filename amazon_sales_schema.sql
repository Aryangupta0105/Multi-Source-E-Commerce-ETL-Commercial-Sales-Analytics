CREATE DATABASE ecommernce_db;
SELECT * FROM ecommerce_db.amazon_sales;
SELECT * FROM ecommernce_db.`amazon sale`;
SET SQL_SAFE_UPDATES = 0;
SELECT * FROM ecommernce_db.`amazon sale`;
describe ecommernce_db. `amazon sale`;
SELECT
	count(*) AS total_rows,
	SUM(CASE WHEN `AMOUNT`IS NULL THEN 1 ELSE 0 END) AS null_amounts,
    SUM(CASE WHEN `Courier status` IS NULL OR `Courier status`= '' THEN 1 ELSE 0 END) AS missing_courier,
    SUM(CASE WHEN `Ship-city` IS NULL OR `Ship-city` ='' THEN 1 ELSE 0 END) AS missing_cities,
    SUM(CASE WHEN `currency` IS NULL OR `currency` = '' THEN 1 ELSE 0 END) AS missing_currency
FROM ecommernce_db.`amazon sale`;
SELECT 
    `Status`, 
    COUNT(*) AS total_missing_courier
FROM ecommernce_db.`amazon sale`
WHERE `Courier Status` IS NULL OR `Courier Status` = ''
GROUP BY `Status`
ORDER BY total_missing_courier DESC;
UPDATE ecommernce_db.`amazon sale`
SET `Courier Status` = 'Cancelled'
WHERE (`Courier Status` IS NULL OR `Courier Status` = '')
  AND `Status` = 'Cancelled';
  UPDATE ecommernce_db.`amazon sale`
SET `Courier Status` = 'Unknown'
WHERE `Courier Status` IS NULL OR `Courier Status` = '';
SELECT `Date` 
FROM ecommernce_db.`amazon sale` 
WHERE `Date` IS NOT NULL 
LIMIT 10;
UPDATE ecommernce_db.`amazon sale`
SET `Date` = STR_TO_DATE(`Date`, '%m-%d-%y')
WHERE `Date` IS NOT NULL;
ALTER TABLE ecommernce_db.`amazon sale`
MODIFY COLUMN `Date` DATE;
SELECT 
    MIN(`Date`) AS earliest_order,
    MAX(`Date`) AS latest_order,
    COUNT(DISTINCT `Date`) AS distinct_days
FROM ecommernce_db.`amazon sale`;
UPDATE ecommernce_db.`amazon sale`
SET 
    `Category` = LOWER(TRIM(`Category`)),
    `Status` = TRIM(`Status`),
    `Fulfilment` = TRIM(`Fulfilment`),
    `ship-service-level` = TRIM(`ship-service-level`),
    `ship-city` = UPPER(TRIM(`ship-city`)),
    `ship-state` = UPPER(TRIM(`ship-state`));
    -- Check distinct product categories
SELECT `Category`, COUNT(*) AS count
FROM ecommernce_db.`amazon sale`
GROUP BY `Category`
ORDER BY count DESC;

-- Check top delivery states for typos or variations
SELECT `ship-state`, COUNT(*) AS count
FROM ecommernce_db.`amazon sale`
GROUP BY `ship-state`
ORDER BY count DESC
LIMIT 15;
SELECT 
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(`Qty`) AS total_units_sold,
    ROUND(SUM(`Amount`), 2) AS total_gross_revenue,
    ROUND(AVG(`Amount`), 2) AS average_order_value
FROM ecommernce_db.`amazon sale`
WHERE `Status` NOT LIKE '%Cancel%';
SELECT 
    `Category`,
    COUNT(DISTINCT `Order ID`) AS order_count,
    SUM(`Qty`) AS units_sold,
    ROUND(SUM(`Amount`), 2) AS total_revenue,
    ROUND(SUM(`Amount`) * 100.0 / (SELECT SUM(`Amount`) FROM ecommernce_db.`amazon sale` WHERE `Status` NOT LIKE '%Cancel%'), 2) AS revenue_share_pct
FROM ecommernce_db.`amazon sale`
WHERE `Status` NOT LIKE '%Cancel%'
GROUP BY `Category`
ORDER BY total_revenue DESC;
SELECT 
    DATE_FORMAT(`Date`, '%Y-%m') AS sale_month,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(`Qty`) AS units_sold,
    ROUND(SUM(`Amount`), 2) AS monthly_revenue
FROM ecommernce_db.`amazon sale`
WHERE `Status` NOT LIKE '%Cancel%'
GROUP BY DATE_FORMAT(`Date`, '%Y-%m')
ORDER BY sale_month ASC;
SELECT 
    `Status`,
    COUNT(*) AS total_orders,
    ROUND(SUM(`Amount`), 2) AS total_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ecommernce_db.`amazon sale`), 2) AS order_percentage
FROM ecommernce_db.`amazon sale`
GROUP BY `Status`
ORDER BY total_orders DESC;
SELECT 
    `ship-state`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(SUM(`Amount`), 2) AS total_revenue,
    ROUND(SUM(`Amount`) * 100.0 / (SELECT SUM(`Amount`) FROM ecommernce_db.`amazon sale` WHERE `Status` NOT LIKE '%Cancel%'), 2) AS revenue_share_pct
FROM ecommernce_db.`amazon sale`
WHERE `Status` NOT LIKE '%Cancel%' 
  AND `ship-state` IS NOT NULL
GROUP BY `ship-state`
ORDER BY total_revenue DESC
LIMIT 10;
SELECT 
    `Fulfilment`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    ROUND(SUM(CASE WHEN `Status` NOT LIKE '%Cancel%' THEN `Amount` ELSE 0 END), 2) AS realized_revenue,
    ROUND(AVG(CASE WHEN `Status` NOT LIKE '%Cancel%' THEN `Amount` ELSE NULL END), 2) AS avg_order_value,
    ROUND(SUM(CASE WHEN `Status` LIKE '%Cancel%' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS cancellation_rate_pct
FROM ecommernce_db.`amazon sale`
GROUP BY `Fulfilment`;
CREATE OR REPLACE VIEW ecommernce_db.vw_sales_analytics AS
SELECT 
    `Order ID` AS order_id,
    `Date` AS order_date,
    `Status` AS order_status,
    CASE 
        WHEN `Status` LIKE '%Cancel%' THEN 1 
        ELSE 0 
    END AS is_cancelled,
    `Fulfilment` AS fulfillment_channel,
    `ship-service-level` AS ship_service_level,
    `Category` AS product_category,
    `Size` AS product_size,
    `Qty` AS quantity,
    `Amount` AS revenue,
    `Courier Status` AS courier_status,
    `ship-city` AS ship_city,
    `ship-state` AS ship_state,
    `ship-postal-code` AS postal_code
FROM ecommernce_db.`amazon sale`;
CREATE TABLE ecommernce_db.dim_date AS
SELECT DISTINCT
    `Date` AS date_id,
    YEAR(`Date`) AS calendar_year,
    MONTH(`Date`) AS month_num,
    MONTHNAME(`Date`) AS month_name,
    QUARTER(`Date`) AS calendar_quarter,
    DAYNAME(`Date`) AS day_of_week
FROM ecommernce_db.`amazon sale`
WHERE `Date` IS NOT NULL
ORDER BY date_id;
CREATE TABLE ecommernce_db.dim_date AS
SELECT DISTINCT
    `Date` AS date_id,
    YEAR(`Date`) AS calendar_year,
    MONTH(`Date`) AS month_num,
    MONTHNAME(`Date`) AS month_name,
    QUARTER(`Date`) AS calendar_quarter,
    DAYNAME(`Date`) AS day_of_week
FROM ecommernce_db.`amazon sale`
WHERE `Date` IS NOT NULL
ORDER BY date_id;

ALTER TABLE ecommernce_db.dim_date ADD PRIMARY KEY (date_id);
CREATE TABLE ecommernce_db.dim_product AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY `Category`, `Size`) AS product_id,
    `Category` AS category,
    `Size` AS size
FROM (
    SELECT DISTINCT `Category`, `Size`
    FROM ecommernce_db.`amazon sale`
) p;

ALTER TABLE ecommernce_db.dim_product ADD PRIMARY KEY (product_id);
CREATE TABLE ecommernce_db.dim_geography AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY `ship-state`, `ship-city`) AS geo_id,
    `ship-city` AS city,
    `ship-state` AS state,
    `ship-postal-code` AS postal_code
FROM (
    SELECT DISTINCT `ship-city`, `ship-state`, `ship-postal-code`
    FROM ecommernce_db.`amazon sale`
    WHERE `ship-city` IS NOT NULL
) g;

ALTER TABLE ecommernce_db.dim_geography ADD PRIMARY KEY (geo_id);
CREATE TABLE ecommernce_db.fact_sales AS
SELECT 
    s.`Order ID` AS order_id,
    s.`Date` AS date_id,
    p.product_id,
    g.geo_id,
    s.`Status` AS order_status,
    s.`Fulfilment` AS fulfillment_channel,
    s.`ship-service-level` AS service_level,
    s.`Courier Status` AS courier_status,
    s.`Qty` AS quantity,
    s.`Amount` AS revenue,
    CASE WHEN s.`Status` LIKE '%Cancel%' THEN 1 ELSE 0 END AS is_cancelled
FROM ecommernce_db.`amazon sale` s
LEFT JOIN ecommernce_db.dim_product p 
    ON s.`Category` = p.category AND s.`Size` = p.size
LEFT JOIN ecommernce_db.dim_geography g 
    ON s.`ship-city` = g.city 
    AND s.`ship-state` = g.state 
    AND (s.`ship-postal-code` = g.postal_code OR (s.`ship-postal-code` IS NULL AND g.postal_code IS NULL)); 
    SELECT 
    (SELECT COUNT(*) FROM ecommernce_db.`amazon sale`) AS raw_rows,
    (SELECT COUNT(*) FROM ecommernce_db.fact_sales) AS fact_rows; 
CREATE OR REPLACE VIEW ecommernce_db.vw_dataset_clean AS
SELECT 
    `Order ID` AS order_id,
    `Date` AS order_date,
    `Category` AS category,
    `Amount` AS revenue,
    `Status` AS status
FROM ecommernce_db.`your_raw_table`;

USE ecommerce;
SET SQL_SAFE_UPDATES = 0;
USE ecommerce;

SELECT * FROM international_sales LIMIT 5;
SELECT COUNT(*) AS total_raw_rows FROM international_sales;
SHOW DATABASES;
USE ecommemce_db;
USE ecommernce_db;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM `international sale report`
WHERE `CUSTOMER` IS NULL 
   OR TRIM(`CUSTOMER`) = ''
   OR `CUSTOMER` IN ('Months', 'CUSTOMER')
   OR `DATE` = 'CUSTOMER';
   UPDATE `international sale report`
SET 
    `CUSTOMER` = UPPER(TRIM(`CUSTOMER`)),
    `Style`    = UPPER(TRIM(`Style`)),
    `SKU`      = UPPER(TRIM(`SKU`)),
    `Size`     = UPPER(TRIM(`Size`)),
    `Months`   = TRIM(`Months`);
    UPDATE `international sale report`
SET `DATE` = NULL
WHERE `DATE` IS NULL OR TRIM(`DATE`) = '';
UPDATE `international sale report`
SET `DATE` = STR_TO_DATE(CONCAT('01-', TRIM(`Months`)), '%d-%b-%y')
WHERE `DATE` IS NULL 
  AND `Months` IS NOT NULL 
  AND `Months` != '';
  SELECT COUNT(*) AS remaining_null_dates
FROM `international sale report`
WHERE `DATE` IS NULL;
UPDATE `international sale report`
SET 
    `PCS` = IFNULL(`PCS`, 0),
    `RATE` = IFNULL(`RATE`, 0),
    `GROSS AMT` = IFNULL(`GROSS AMT`, 0);
UPDATE `international sale report`
SET `DATE` = STR_TO_DATE(`DATE`, '%m-%d-%Y')
WHERE `DATE` LIKE '__-__-____';
RENAME TABLE `international sale report` TO international_sales;
SELECT * FROM international_sales LIMIT 100;
SELECT 
    CUSTOMER,
    SUM(PCS) AS total_units,
    ROUND(SUM(`GROSS AMT`), 2) AS total_gross_revenue
FROM international_sales
GROUP BY CUSTOMER
ORDER BY total_gross_revenue DESC
LIMIT 5;
