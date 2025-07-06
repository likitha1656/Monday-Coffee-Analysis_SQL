-- PROJECT GOAL
-- To analyze customer, product, and sales data across different cities to identify the best cities for opening new Monday Coffee branches.
-- BANGALORE, CHENNAI, PUNE (recommendation)

use monday_coffee;
select * from city limit 5;
select * from customers limit 5;
select * from products limit 5;
select * from sales limit 5;

---------------------------------------------------------------------

-- Total sales per city
SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city ci ON cu.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY total_revenue DESC;

-- PUNE, CHENNAI, BANGLORE, JAIPUR, DELHI ARE THE TOP 5 CITIES

--------------------------------------------------------------------

-- Number of Unique Customers per City
SELECT 
    ci.city_name,
    COUNT(DISTINCT cu.customer_id) AS active_customers
FROM customers cu
JOIN city ci ON cu.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY active_customers DESC;

-- JAIPUR, DELHI, PUNE, CHENNAI, BANGLORE -- MORE ACTIVE CUTOMERS

----------------------------------------------------------------
-- customer satisfaction 

SELECT 
    ci.city_name,
    ROUND(AVG(s.rating), 2) AS avg_rating,
    COUNT(s.rating) AS num_ratings
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city ci ON cu.city_id = ci.city_id
GROUP BY ci.city_name
HAVING COUNT(s.rating) > 0
ORDER BY avg_rating DESC;

-- CHENNAI, BANGLORE, PUNE, AHMEDABAD, LUCKNOW

----------------------------------------------------------------------
SELECT 
    ci.city_name,
    ci.estimated_rent,
    SUM(s.total) AS total_revenue,
    COUNT(DISTINCT cu.customer_id) AS unique_customers,
    ROUND(AVG(s.rating), 2) AS avg_rating,
    ROUND(SUM(s.total) / ci.estimated_rent, 2) AS revenue_per_rent_unit
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city ci ON cu.city_id = ci.city_id
GROUP BY ci.city_name, ci.estimated_rent
HAVING SUM(s.total) > 0
ORDER BY revenue_per_rent_unit DESC;

-- BANGLORE has highest avg rating with lowest rent -- huge potential

------------------------------------------------------------------
-- Revenue per Customer

SELECT 
    ci.city_name,
    ROUND(SUM(s.total) / COUNT(DISTINCT cu.customer_id), 2) AS revenue_per_customer
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city ci ON cu.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY revenue_per_customer DESC;

-- PUNE, CHENNAI, BANGLORE, JAIPUR AND DELHI -- TOP 5

-----------------------------------------------------------------------
-- Oders per city -- total transactions

SELECT 
    ci.city_name,
    COUNT(s.sale_id) AS total_orders
FROM sales s
JOIN customers cu ON s.customer_id = cu.customer_id
JOIN city ci ON cu.city_id = ci.city_id
GROUP BY ci.city_name
ORDER BY total_orders DESC;

-- PUNE, CHENNAI, BANGLORE -- TOP -- BUSY 

-----------------
SELECT 
    ROUND(AVG(p.price), 2) AS avg_price_sold
FROM sales s
JOIN products p ON s.product_id = p.product_id;




