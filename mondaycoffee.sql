use monday_coffee;
select * from sales;
select * from city;
select * from customers;
select * from products;



-- how many people in each city are estimated to consume coffee, given that 25% of the population does?
select city_name, round((population * 0.25) / 10000000, 2) from city order by population desc;


-- What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
select c.city_name, 
sum(s.total) as revenue_of_last_quarter from sales as s
inner join customers as co on s.customer_id = co.customer_id
inner join city as c on c.city_id = co.city_id
where s.sale_date between '2023-10-01' and '2023-12-31'
group by c.city_name
order by revenue_of_last_quarter desc

-- How many units of each coffee product have been sold?
select p.product_name, count(s.sale_id) as total_units_sold from products as p
left join sales as s on p.product_id =  s.product_id
group by p.product_id
order by total_units_sold desc

-- What is the average sales amount per customer in each city?
select ci.city_name, count(distinct s.customer_id) as total_customers,  round(sum(s.total),2) as avg_sales_amount from sales as s
join customers as c on s.customer_id = c.customer_id
join city as ci on c.city_id = ci.city_id
group by ci.city_name
order by avg_sales_amount desc


-- Provide a list of cities along with their populations and estimated coffee consumers. (25%)
select city_name, population as total_population, (population * 0.25) as estimated_coffee_consumers 
from city 
group by city_name, population
order by total_population desc

-- top selling products by city
-- What are the top 3 selling products in each city based on sales volume?
with totalsalesofeachproductwithincity as(
select ci.city_name, 
sum(s.total) as total_sales, p.product_name
from sales as s
join products as p on s.product_id = p.product_id
join customers as c on s.customer_id = c.customer_id
join city as ci on c.city_id = ci.city_id
group by ci.city_name, p.product_name
order by ci.city_name, sum(s.total) desc)

,
ranked_products as (
select city_name, product_name, total_sales, 
rank() over (partition by city_name order by total_sales desc) as `rank` from 
totalsalesofeachproductwithincity )

select city_name, product_name, total_sales, `rank` from ranked_products
where `rank` <=3
ORDER BY 
    city_name, total_sales DESC;


-- How many unique customers are there in each city who have purchased coffee products?
select   ci.city_name, count(distinct c.customer_id) as unique_customers
from sales as s
join products as p on s.product_id = p.product_id
join customers as c on s.customer_id = c.customer_id
join city as ci on c.city_id = ci.city_id
where p.product_id between 1 and 14
group by ci.city_name
order by count(distinct c.customer_id) desc


-- Find each city and their average sale per customer and avg rent per customer
-- avg rent per customer, avg sale per customer (city)

with avgrent_percustomer as (
select c.city_name, count(cu.customer_id) as totalcustomers, 
round((c.estimated_rent)/count(cu.customer_id),2) as avg_rent  from customers as cu
join city as c on cu.city_id = c.city_id 
group by c.city_name, c.estimated_rent),

-- city | customer | avg sale
avgsale_percustomer as (
select ci.city_name, count(cu.customer_id) as total_customers, round(sum(s.total)/count(cu.customer_id),2) as avg_sale
from sales as s
join customers as cu on s.customer_id = cu.customer_id
join city as ci on cu.city_id = ci.city_id 
group by ci.city_name)

select avr.city_name, avr.avg_rent as avg_rent_per_customer, avs.avg_sale as avg_sale_per_customer 
from avgrent_percustomer as avr
join avgsale_percustomer as avs on avr.city_name = avs.city_name
order by avr.city_name


-- Monthly Sales Growth
-- Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly)
with total_sales_per_month_year as(
select ci.city_name, year(s.sale_date) as year, month(s.sale_date) as month, sum(s.total) as current_month_sales from sales as s
join customers as cu on s.customer_id = cu.customer_id
join city as ci on cu.city_id = ci.city_id
group by city_name, year, month ),

past_month_sale_total as
(select city_name, year, month,
lag(current_month_sales,1) over(partition by city_name order by year, month) as past_month_sale
from total_sales_per_month_year)


select abc.city_name, abc.year, abc.month, abc.current_month_sales, def.past_month_sale,
(abc.current_month_sales-def.past_month_sale)/(past_month_sale)*100 as growth_rate from 
total_sales_per_month_year as abc
join past_month_sale_total as def on abc.city_name = def.city_name 
AND abc.year = def.year 
 AND abc.month = def.month
having growth_rate is not null
order by city_name, year, month


-- Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, 
-- estimated coffee consumer
-- 

WITH city_table AS (
  SELECT 
    ci.city_name,
    SUM(s.total) AS total_revenue,
    COUNT(DISTINCT s.customer_id) AS total_cx,
    ROUND(
      SUM(s.total) / CAST(COUNT(DISTINCT s.customer_id) AS DECIMAL), 2
    ) AS avg_sale_pr_cx
  FROM sales AS s
  JOIN customers AS c ON s.customer_id = c.customer_id
  JOIN city AS ci ON ci.city_id = c.city_id
  GROUP BY 1
  ORDER BY 2 DESC
),
city_rent AS (
  SELECT 
    city_name,
    estimated_rent,
    ROUND((population * 0.25) / 1000000, 3) AS estimated_coffee_consumer_in_millions
  FROM city
)
SELECT 
  cr.city_name,
  total_revenue,
  cr.estimated_rent AS total_rent,
  ct.total_cx,
  estimated_coffee_consumer_in_millions,
  ct.avg_sale_pr_cx,
  ROUND(
    CAST(cr.estimated_rent AS DECIMAL) / CAST(ct.total_cx AS DECIMAL), 2
  ) AS avg_rent_per_cx
FROM city_rent AS cr
JOIN city_table AS ct ON cr.city_name = ct.city_name
ORDER BY 2 DESC;








