/*Q1. Top 5 Most Frequently Ordered Dishes
Question:
Write a query to find the top 5 most frequently ordered dishes by the customer "Arjun Mehta"  */

SELECT 
    c.customer_name,
    o.order_item AS dishes,
    count(o.order_item) AS number_of_orders
FROM 
    orders o
JOIN 
    customers c
    ON c.customer_id = o.customer_id
WHERE 
    c.customer_id = 1 
GROUP BY
    o.order_item,
    c.customer_name,
    c.customer_id
ORDER BY number_of_orders DESC;

/*Q2. Popular Time Slots
Question:
Identify the time slots during which the most orders are placed, based on 2-hour intervals. */
SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
    END AS time_slots,
    count(order_id) AS total_orders
FROM 
    orders
GROUP BY time_slots
ORDER BY total_orders DESC


/*Q3. Order Value Analysis
Question:
Find the average order value (AOV) per customer who has placed more than 750 orders.
Return: customer_name, aov (average order value).*/


SELECT
    customer_name,
    count(order_id) AS total_orders,
    ROUND(AVG(total_amount)::NUMERIC, 2) AS AOV
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY    
    customer_name
HAVING count(order_id) > 750
ORDER BY
    total_orders DESC

/* Q4. High-Value Customers
Question:
List the customers who have spent more than 100K in total on food orders.
Return: customer_name, customer_id. */

SELECT
    customer_name,
    sum(total_amount) AS amount_spent
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY    
    customer_name
HAVING sum(total_amount) > 100000
ORDER BY
    amount_spent DESC


/*Q5. Orders Without Delivery
Question:
Write a query to find orders that were placed but not delivered.
Return: restaurant_name, city, and the number of not delivered orders. */

SELECT
    r.restaurant_name,
    r.city,
    count(o.order_status) AS total_non_delivery
FROM orders o
LEFT JOIN deliveries d 
    ON d.order_id = o.order_id
LEFT JOIN restaurants r 
    ON o.restaurant_id = r.restaurant_id
WHERE   
    order_status = 'Not Fulfilled'
GROUP BY 
    r.restaurant_name,
    r.city
ORDER BY 
    total_non_delivery DESC; 

/*Q6. Restaurant Revenue Ranking
Question:
Rank restaurants by their total revenue from the last year.
Return: restaurant_name, total_revenue, and their rank within their city.*/

WITH ranking_table AS
(
SELECT
    r.city AS city,
    r.restaurant_name AS restaurant_name,
    sum(o.total_amount) AS total_revenue,
    DENSE_RANK () OVER(PARTITION BY r.city ORDER BY sum(o.total_amount) DESC )AS rank
FROM orders o 
JOIN restaurants r 
    ON o.restaurant_id = r.restaurant_id
WHERE EXTRACT (YEAR FROM o.order_date) = 2024
GROUP BY
    r.restaurant_name,
    r.city
ORDER BY 
    r.city,
    total_revenue DESC
)

SELECT 
    city,
    restaurant_name,
    total_revenue
FROM ranking_table
WHERE rank = 1

/*Q7. Most Popular Dish by City
Question:
Identify the most popular dish in each city based on the number of orders.*/

SELECT
    city,
    order_item,
    total_orders
FROM
 (   SELECT
        r.city AS city,
        o.order_item AS order_item,
        count(o.order_item) AS total_orders,
        DENSE_RANK() OVER(PARTITION BY r.city ORDER BY count(o.order_item) DESC )AS rank
    FROM orders o 
    JOIN restaurants r 
        ON o.restaurant_id = r.restaurant_id
    GROUP BY
        o.order_item,
        r.city
    ORDER BY 
        r.city,
        total_orders DESC
 ) AS sb_1
 WHERE rank = 1
    

/*Q8. Customer Churn
Question:
Find customers who haven’t placed an order in 2024 but did in 2023*/

SELECT 
    DISTINCT o.customer_id,
     c.customer_name
FROM orders o 
RIGHT JOIN customers c 
    ON o.customer_id = c.customer_id
WHERE
    EXTRACT (YEAR FROM order_date) = 2023
    AND
    c.customer_id NOT IN 
                        (SELECT DISTINCT customer_id FROM orders
                        WHERE EXTRACT(YEAR FROM order_date) = 2024)


/*Q9. Cancellation Rate Comparison
Question:
Calculate and compare the order cancellation rate for each restaurant between the current year
and the previous year.*/

WITH cancellation_ratio_23
AS
(
    SELECT 
        o.restaurant_id AS restaurant_id,
        COUNT(o.order_id) as total_orders,
        COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
    FROM orders o 
    LEFT JOIN deliveries d 
        ON o.order_id = d.order_id
    WHERE 
        EXTRACT (YEAR FROM order_date) = 2023
    GROUP BY o.restaurant_id
),

cancellation_ratio_24
AS
(
    SELECT 
        o.restaurant_id AS restaurant_id,
        COUNT(o.order_id) as total_orders,
        COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS not_delivered
    FROM orders o 
    LEFT JOIN deliveries d 
        ON o.order_id = d.order_id
    WHERE 
        EXTRACT (YEAR FROM order_date) = 2024
    GROUP BY o.restaurant_id
),

last_year_data
AS
(
    SELECT
        restaurant_id,
        total_orders,
        not_delivered,
        ROUND(not_delivered::numeric / total_orders::numeric * 100, 2) AS cancel_ratio
    FROM 
        cancellation_ratio_23
),
current_year_data
AS
(
    SELECT
        restaurant_id,
        total_orders,
        not_delivered,
        ROUND(not_delivered::numeric / total_orders::numeric * 100, 2) AS cancel_ratio
    FROM 
        cancellation_ratio_24
)

SELECT
    current_year_data.restaurant_id AS restaurant_id,
    current_year_data.cancel_ratio AS cancel_ratio_2024,
    last_year_data.cancel_ratio AS cancel_ratio_2023
FROM current_year_data
JOIN last_year_data
    ON current_year_data.restaurant_id = last_year_data.restaurant_id


/*Q10. Rider Average Delivery Time
Question:
Determine each rider's average delivery time.*/
SELECT
    r.rider_name,
    ROUND(AVG(EXTRACT (MINUTE FROM d.delivery_time)), 2) AS avg_delivery_time
FROM deliveries d
RIGHT JOIN riders r 
    ON r.rider_id = d.rider_id
GROUP BY
    r.rider_name
ORDER BY 
    avg_delivery_time


/*Q11. Monthly Restaurant Growth Ratio
Question:
Calculate each restaurant's growth ratio based on the total number of delivered orders since its
joining.*/
