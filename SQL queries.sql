-- Exlporing the tables and their columns in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE table_schema = 'public';

SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- Exploring Tables
SELECT COUNT(customer_id) FROM customers;
-- Total 5K unique customers, PK customer_id

-- Exploring products table
SELECT * FROM products;

SELECT DISTINCT product_name, restaurent_id, 
COUNT(restaurent_id) 
FROM products
GROUP BY 1, 2
HAVING COUNT(restaurent_id) > 1
ORDER BY 1, 2;
-- same dish from same restaurent but price varies due to quantity change

SELECT DISTINCT cusine_type FROM products;
-- product_id is the PK, total 2123 records, only 27 distinct product_name, 
-- basically these resutaurent serve the same dish in different quantities which is identified by the price difference of the product
-- 5 cusine types

-- Exploring products table
SELECT * FROM restaurants;
-- 200 restaurents, restaurent_id is the PK

-- Exploring orders table
SELECT * FROM orders;

SELECT order_id, customer_id, restaurent_id,
COUNT(DISTINCT order_id), COUNT(DISTINCT customer_id), COUNT(DISTINCT restaurent_id), COUNT(DISTINCT product_id)
FROM orders
GROUP BY 1,2,3
HAVING COUNT(DISTINCT order_id) > 1 
OR COUNT(DISTINCT customer_id) > 1 
OR COUNT(DISTINCT restaurent_id) > 1
OR COUNT(DISTINCT product_id) > 1
-- No PK, 9060 records, 
-- Each row represent order of a unique item and its quantity, the key is each order is from same customer and restaurent, i.e products of only one unique restaurent can be placed in a order

-- order cancellation
SELECT 
COUNT(DISTINCT order_id) FILTER(WHERE order_status = 'Delivered'), 
COUNT(DISTINCT order_id) FILTER(WHERE order_status = 'Cancelled')
FROM orders;

-- Exlporing Dimensions
-- Exlporing customer - age Group
SELECT 
EXTRACT(YEAR FROM CURRENT_DATE) - MIN(EXTRACT (YEAR FROM dob)) AS max_age, 
EXTRACT(YEAR FROM CURRENT_DATE) - MAX(EXTRACT (YEAR FROM dob)) AS min_age
FROM customers;
-- Analysed minimum and maximum age of customer

-- Analysing customers age by bins
SELECT 
CASE
	WHEN (CURRENT_DATE - dob)/365 >= '18' AND (CURRENT_DATE - dob)/365 < '26' THEN '18 - 25'
	WHEN (CURRENT_DATE - dob)/365 >= '26' AND (CURRENT_DATE - dob)/365 < '31' THEN '26 - 30'
	WHEN (CURRENT_DATE - dob)/365 >= '31' AND (CURRENT_DATE - dob)/365 < '36' THEN '31 - 25'
	WHEN (CURRENT_DATE - dob)/365 >= '36' AND (CURRENT_DATE - dob)/365 < '41' THEN '36 - 40'
	WHEN (CURRENT_DATE - dob)/365 >= '41' AND (CURRENT_DATE - dob)/365 < '51' THEN '41 - 50'
	WHEN (CURRENT_DATE - dob)/365 >= '51' THEN 'Greater than 50' 
END AS age_bin, COUNT(customer_id) AS total_Customers
FROM customers
GROUP BY 1
ORDER BY 1
-- Young customers in the age group of 18 - 40 is very less compared to people greater than 40 - 60

-- user_signups data anaysis
SELECT 
EXTRACT(MONTH FROM signup_date) AS month, EXTRACT(YEAR FROM signup_date) AS year, COUNT(customer_id)
FROM customers
GROUP BY 1, 2
ORDER BY 2, 1
-- starts from 11-22 to 11-25 (3 yr data)

-- customers signups by year
SELECT EXTRACT(YEAR FROM signup_date) AS year, COUNT(customer_id)
FROM customers
GROUP BY 1 
ORDER BY 1;

-- customer signups by quater
SELECT EXTRACT(YEAR FROM signup_date) AS year, EXTRACT(QUARTER FROM signup_date) AS year, COUNT(customer_id)
FROM customers
GROUP BY 1, 2
ORDER BY 1, 2;

-- no of gold customers
SELECT gold_member, COUNT(customer_id) AS total
FROM customers
GROUP BY 1;


-- Restaurent density by area
SELECT area, COUNT(restaurent_id) AS total_restaurents
FROM restaurants
GROUP BY 1
ORDER BY 2 DESC;

-- Restaurent_type anlysis
SELECT restaurent_type, COUNT(restaurent_id) AS total_restaurents
FROM restaurants
GROUP BY 1
ORDER BY 2 DESC;

-- order date analysis
SELECT EXTRACT(YEAR FROM order_time), EXTRACT(MONTH FROM order_time) FROM orders
GROUP BY 1, 2
ORDER BY 2;

-- order calcellation by qtr
SELECT EXTRACT(YEAR FROM order_time) AS year, EXTRACT(QUARTER FROM order_time) AS qtr, COUNT(DISTINCT order_id)
FROM orders
WHERE order_status = 'Cancelled'
AND EXTRACT(QUARTER FROM order_time) != 4
GROUP BY 1, 2;

-- total orders by qtr
SELECT EXTRACT(YEAR FROM order_time) AS year, EXTRACT(QUARTER FROM order_time) AS qtr, COUNT(DISTINCT order_id)
FROM orders
WHERE order_status = 'Delivered'
AND EXTRACT(QUARTER FROM order_time) != 4
GROUP BY 1, 2;

-- total sales by qtr
SELECT EXTRACT(YEAR FROM order_time) AS year, EXTRACT(QUARTER FROM order_time) AS qtr, SUM(total_amount)
FROM orders
WHERE order_status = 'Delivered'
AND EXTRACT(QUARTER FROM order_time) != 4
GROUP BY 1, 2;

-- customer preferred payment type
SELECT payment_type, COUNT(DISTINCT order_id)
FROM orders
GROUP BY 1;

-- user retention for last 3 months, (condition customer needs to be made atleast one order in previous and current month)
with cte0 AS
(SELECT 
COUNT(DISTINCT t1.customer_id) AS Jly_customers,
COUNT(DISTINCT t2.customer_id) AS aug_customers
FROM orders AS t1
LEFT JOIN orders AS t2
ON t1.customer_id = t2.customer_id
AND EXTRACT(MONTH FROM t2.order_time) - EXTRACT(MONTH FROM t1.order_time) = 1
WHERE t1.order_status = 'Delivered'
AND EXTRACT(MONTH FROM t1.order_time) = '7'),
cte1 AS
(SELECT 
COUNT(DISTINCT t1.customer_id) AS aug_customers,
COUNT(DISTINCT t2.customer_id) AS sep_customers
FROM orders AS t1
LEFT JOIN orders AS t2
ON t1.customer_id = t2.customer_id
AND EXTRACT(MONTH FROM t2.order_time) - EXTRACT(MONTH FROM t1.order_time) = 1
WHERE t1.order_status = 'Delivered'
AND EXTRACT(MONTH FROM t1.order_time) = '8'),
cte2 AS
(SELECT 
COUNT(DISTINCT t1.customer_id) AS sep_customers,
COUNT(DISTINCT t2.customer_id) AS oct_customers
FROM orders AS t1
LEFT JOIN orders AS t2
ON t1.customer_id = t2.customer_id
AND EXTRACT(MONTH FROM t2.order_time) - EXTRACT(MONTH FROM t1.order_time) = 1
WHERE t1.order_status = 'Delivered'
AND EXTRACT(MONTH FROM t1.order_time) = '9')
SELECT 
ROUND((a0.aug_customers::DECIMAL/a0.jly_customers)*100,2) AS Aug_retention_percent, 
ROUND((a1.sep_customers::DECIMAL/a1.aug_customers)*100,2) AS Sep_retention_percent, 
ROUND((oct_customers::DECIMAL/a2.sep_customers)*100,2) AS Oct_retention_percent
FROM cte0 AS a0, cte1 AS a1, cte2 AS a2

-- Customer churn rate for last 3 months
WITH cte0 AS
(SELECT
COUNT(DISTINCT t1.customer_id) AS Jly_customers,
ABS(COUNT(DISTINCT t1.customer_id) - COUNT(DISTINCT t2.customer_id)) AS aug_churn
FROM orders AS t1
LEFT JOIN orders AS t2
ON t1.customer_id = t2.customer_id
AND EXTRACT(MONTH FROM t2.order_time) - EXTRACT(MONTH FROM t1.order_time) = 1
WHERE t1.order_status = 'Delivered'
AND EXTRACT(MONTH FROM t1.order_time) = '7'),
cte1 AS
(SELECT
COUNT(DISTINCT t1.customer_id) AS aug_customers,
ABS(COUNT(DISTINCT t1.customer_id) - COUNT(DISTINCT t2.customer_id)) AS sep_churn
FROM orders AS t1
LEFT JOIN orders AS t2
ON t1.customer_id = t2.customer_id
AND EXTRACT(MONTH FROM t2.order_time) - EXTRACT(MONTH FROM t1.order_time) = 1
WHERE t1.order_status = 'Delivered'
AND EXTRACT(MONTH FROM t1.order_time) = '8'),
cte2 AS
(SELECT
COUNT(DISTINCT t1.customer_id) AS sep_customers,
ABS(COUNT(DISTINCT t1.customer_id) - COUNT(DISTINCT t2.customer_id)) AS oct_churn
FROM orders AS t1
LEFT JOIN orders AS t2
ON t1.customer_id = t2.customer_id
AND EXTRACT(MONTH FROM t2.order_time) - EXTRACT(MONTH FROM t1.order_time) = 1
WHERE t1.order_status = 'Delivered'
AND EXTRACT(MONTH FROM t1.order_time) = '9')
SELECT 
ROUND((aug_churn/Jly_customers::DECIMAL)*100,2) AS aug_churn,
ROUND((sep_churn/aug_customers::DECIMAL)*100,2) AS sep_churn,
ROUND((oct_churn/sep_customers::DECIMAL)*100,2) AS oct_churn
FROM cte0, cte1, cte2;

--TOP 5 ordered dish
with cte AS
(SELECT product_name, SUM(quantity) AS total_ordered, DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS ranked
FROM products AS t1
JOIN orders AS t2
ON t1.product_id = t2.product_id
WHERE order_status = 'Delivered'
GROUP BY 1
ORDER BY 2 DESC)
SELECT * FROM cte
WHERE ranked < 6;

-- Top 3 cusine and the quantity ordered
SELECT cusine_type, SUM(quantity) AS total_ordered
FROM products AS t1
JOIN orders AS t2
ON t1.product_id = t2.product_id
GROUP BY 1
ORDER BY 2 DESC;

-- Avg, min, max time between order and delivery
WITH cte AS
(SELECT order_id, delivery_time - order_time AS total_time
FROM orders
WHERE order_status = 'Delivered'
GROUP BY 1, 2
ORDER BY 2)
SELECT 
AVG(total_time) AS avg_delivery_time, 
MAX(total_time) AS max_delivery_time,
MIN(total_time) AS min_delivery_time
FROM cte;

-- Top 5 restaurents 
SELECT * FROM
(SELECT reataurent_name, 
COUNT(DISTINCT order_id) AS ttl_orders, 
DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT order_id) DESC) AS ranked
FROM restaurants AS t1
JOIN orders AS t2 
ON t1.restaurent_id = t2.restaurent_id
WHERE order_status = 'Delivered'
GROUP BY 1
ORDER BY 2 DESC)
WHERE ranked < 6;

-- Avg amount spent on top 5 dishes
WITH cte AS
(SELECT product_name, SUM(quantity) AS total_ordered, ROUND(AVG(price),2) AS avg_price,
DENSE_RANK() OVER(ORDER BY SUM(quantity) DESC) AS ranked
FROM products AS t1
JOIN orders AS t2
ON t1.product_id = t2.product_id
WHERE order_status = 'Delivered'
GROUP BY 1
ORDER BY 2 DESC)
SELECT product_name, avg_price
FROM cte
WHERE ranked < 6;

-- Avg amt spent on orders month wise
SELECT EXTRACT(MONTH FROM order_time) AS month, ROUND(AVG(total_amount),0) AS avg_amt
FROM orders
GROUP BY 1
ORDER BY 1;

-- Distance between restaurent and customer_location
WITH cte AS
(SELECT order_id, 
(ST_DistanceSphere(
	ST_MakePoint(t1.latitude, t1.longitude),
	ST_MakePoint(t2.latitude, t2.longitude))/1000)::NUMERIC
AS distance_km,
delivery_time - order_time AS del_time
FROM orders AS t1
JOIN restaurants AS t2
ON t1.restaurent_id = t2.restaurent_id
WHERE order_status = 'Delivered'
GROUP BY 1, 2, 3),
cte2 AS -- analysed Min and Max distances
(SELECT 
ROUND(AVG(distance_km),2) AS avg_distance,
ROUND(MIN(distance_km),2) AS min_distance,
ROUND(MAX(distance_km),2) AS max_distance
FROM cte
ORDER BY 1)
SELECT 
CASE 
	WHEN distance_km <= 1.00 THEN 'Less than 1km'
	WHEN distance_km > 1.00 AND distance_km <= 2.00 THEN '1-2 km'
	WHEN distance_km > 2.00 AND distance_km <= 3.00 THEN '2-3 km'
	WHEN distance_km > 3.00 AND distance_km <= 4.00 THEN '3-4 km'
	WHEN distance_km > 4.00 AND distance_km <= 6.00 THEN '4-6 km'
	WHEN distance_km > 6.00 AND distance_km <= 9.00 THEN '6-9 km'
	WHEN distance_km > 9.00 THEN 'more than 9km' END AS distance_bin,
COUNT(DISTINCT order_id) AS orders, AVG(del_time) AS avg_del_time
FROM cte
GROUP BY 1;

-- Order by age group
SELECT 
CASE
	WHEN (CURRENT_DATE - dob)/365 >= '18' AND (CURRENT_DATE - dob)/365 < '26' THEN '18 - 25'
	WHEN (CURRENT_DATE - dob)/365 >= '26' AND (CURRENT_DATE - dob)/365 < '31' THEN '26 - 30'
	WHEN (CURRENT_DATE - dob)/365 >= '31' AND (CURRENT_DATE - dob)/365 < '36' THEN '31 - 25'
	WHEN (CURRENT_DATE - dob)/365 >= '36' AND (CURRENT_DATE - dob)/365 < '41' THEN '36 - 40'
	WHEN (CURRENT_DATE - dob)/365 >= '41' AND (CURRENT_DATE - dob)/365 < '51' THEN '41 - 50'
	WHEN (CURRENT_DATE - dob)/365 >= '51' THEN 'Greater than 50' 
END AS age_bin, COUNT(t1.customer_id) AS total_Customers, 
ROUND((COUNT(DISTINCT order_id)::DECIMAL/(SELECT COUNT(DISTINCT order_id) FROM orders WHERE order_status = 'Delivered')*100),2) AS order_percentage
FROM customers AS t1
LEFT JOIN orders AS t2 
ON t1.customer_id = t2.customer_id
WHERE order_status = 'Delivered'
GROUP BY 1
ORDER BY 1;
