--data cleaning

--to check for duplicates
select transaction_id, count(*)
from sales_store
group by transaction_id
having count(transaction_id)>1

--correction of headers(if any)
select * from sales_store

ALTER TABLE sales_store
RENAME COLUMN porduct_id TO product_id;

--check datatype
select column_name, data_type
from information_schema.columns
where table_name='sales_store'

--check null count
select
    count(*) - count(transaction_id)    as transaction_id_nulls,
    count(*) - count(customer_id)       as customer_id_nulls,
    count(*) - count(customer_name)     as customer_name_nulls,
    count(*) - count(customer_age)      as customer_age_nulls,
    count(*) - count(gender)            as gender_nulls,
    count(*) - count(product_id)        as product_id_nulls,
    count(*) - count(product_name)      as product_name_nulls,
    count(*) - count(product_category)  as product_category_nulls,
    count(*) - count(quantity)          as quantity_nulls,
    count(*) - count(price)             as price_nulls,
    count(*) - count(payment_mode)      as payment_mode_nulls,
    count(*) - count(purchase_date)     as purchase_date_nulls,
    count(*) - count(time_of_purchase)  as time_of_purchase_nulls,
    count(*) - count(status)            as status_nulls
from sales_store;

--treating null values and find the outliers
select * from sales_store
where transaction_id is null
or customer_id is null
or customer_name is null
or customer_age is null
or gender is null
or product_id is null
or product_name is null
or product_category is null
or quantity is null
or price is null
or payment_mode is null
or purchase_date is null
or time_of_purchase is null
or status is null

--delete the outlier
delete from sales_store
where transaction_id is null

select * from sales_store
where customer_name='Ehsaan Ram'

update sales_store
set customer_id='CUST9494'
where transaction_id='TXN977900'


select * from sales_store
where customer_name='Damini Raju'

update sales_store
set customer_id='CUST9494'
where transaction_id='TXN985663'


select * from sales_store
where customer_id='CUST1003'

update sales_store
set customer_name='Mahika Saini', customer_age=35,gender='Male',customer_id='CUST1003'
where transaction_id='TXN432798'

--Data cleaning
select distinct gender
from sales

--cleaning gender
update sales_store
set gender='M' 
where gender='Male'

update sales_store
set gender='F'
where gender='Female'


select distinct payment_mode
from sales_store

update sales_store
set payment_mode='Credit Card'
where payment_mode='CC'

--data analysis--
SELECT * FROM sales_store
-- Q1. What are the top 5 most selling products by quantity?
SELECT product_name,                       -- show the product
       SUM(quantity) AS total_quantity_sold -- add up its quantities
FROM sales_store
WHERE status = 'delivered'                 -- only count delivered orders
GROUP BY product_name                      -- one row per product
ORDER BY total_quantity_sold DESC          -- biggest total first
LIMIT 5;                                   -- keep the top 5

-- Q2.Which products are more frequently cancelled?
select product_name,
COUNT(*) AS cancelled_orders,
SUM(quantity) AS cancelled_units
from sales_store
where status ='cancelled'
group by product_name
order by cancelled_orders desc
SELECT
    CASE
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 5  AND 11 THEN 'Morning (5am-11am)'
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 12 AND 16 THEN 'Afternoon (12pm-4pm)'
        WHEN EXTRACT(HOUR FROM time_of_purchase) BETWEEN 17 AND 20 THEN 'Evening (5pm-8pm)'
        ELSE 'Night (9pm-4am)'
    END AS time_of_day,
    COUNT(*) AS total_orders
FROM sales_store
GROUP BY time_of_day
ORDER BY total_orders DESC;
 
-- (b) by exact hour
SELECT EXTRACT(HOUR FROM time_of_purchase) AS purchase_hour,
       COUNT(*) AS total_orders
FROM sales_store
GROUP BY purchase_hour
ORDER BY total_orders DESC;
 
 
-- Q4. Who are the top 5 highest spending customers?
SELECT customer_id,
       customer_name,
       SUM(price * quantity) AS total_spent
FROM sales_store
WHERE LOWER(status) = 'delivered'
GROUP BY customer_id, customer_name
ORDER BY total_spent DESC
LIMIT 5;
 
 
-- Q5. Which product categories generate the highest revenue?
SELECT product_category,
       SUM(price * quantity) AS total_revenue
FROM sales_store
WHERE LOWER(status) = 'delivered'
GROUP BY product_category
ORDER BY total_revenue DESC;
 
 
-- Q6. What is the return/cancellation rate per product category?
SELECT product_category,
       COUNT(*) AS total_orders,
       COUNT(*) FILTER (WHERE LOWER(status) = 'cancelled') AS cancelled_orders,
       COUNT(*) FILTER (WHERE LOWER(status) = 'returned')  AS returned_orders,
       ROUND(100.0 * COUNT(*) FILTER (WHERE LOWER(status) = 'cancelled') / COUNT(*), 2) AS cancellation_rate_pct,
       ROUND(100.0 * COUNT(*) FILTER (WHERE LOWER(status) = 'returned')  / COUNT(*), 2) AS return_rate_pct
FROM sales_store
GROUP BY product_category
ORDER BY cancellation_rate_pct DESC;
 
 
-- Q7. What is the most preferred payment mode?
SELECT payment_mode,
       COUNT(*) AS total_orders
FROM sales_store
GROUP BY payment_mode
ORDER BY total_orders DESC;
 
 
-- Q8. How does age group affect purchasing behavior?
SELECT
    CASE
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        ELSE '51+'
    END AS age_group,
    COUNT(*)              AS total_orders,
    SUM(quantity)         AS total_units,
    SUM(price * quantity) AS total_revenue
FROM sales_store
WHERE LOWER(status) = 'delivered'
GROUP BY age_group
ORDER BY total_revenue DESC;
 
 
-- Q9. What's the monthly sales trend?
SELECT DATE_TRUNC('month', purchase_date)::date AS month,
       COUNT(*)              AS total_orders,
       SUM(quantity)         AS total_units,
       SUM(price * quantity) AS total_revenue
FROM sales_store
WHERE LOWER(status) = 'delivered'
GROUP BY month
ORDER BY month;
 
 -- Q10. Are certain genders buying more specific product categories?
SELECT product_category,
       gender,
       COUNT(*)      AS total_orders,
       SUM(quantity) AS total_units
FROM sales_store
WHERE LOWER(status) = 'delivered'
GROUP BY product_category, gender
ORDER BY product_category, total_orders DESC;