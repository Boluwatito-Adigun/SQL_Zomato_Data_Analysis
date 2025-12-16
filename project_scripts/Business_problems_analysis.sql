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

WITH unit_delivery_time AS
(
    SELECT
        r.rider_id,
        r.rider_name,
        o.order_time,
        d.delivery_time,
        EXTRACT(EPOCH FROM (d.delivery_time - o.order_time + CASE
        WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day' ELSE INTERVAL '0 day' 
        END))/60 AS time_taken 
    FROM deliveries d
    JOIN orders o 
        ON o.order_id = d.order_id
    JOIN riders r 
        ON r.rider_id = d.rider_id
    GROUP BY
        r.rider_id,
        r.rider_name,
        o.order_time,
        d.delivery_time
    ORDER BY 
        time_taken DESC
)
SELECT
    rider_id,
    rider_name,
    ROUND(AVG(time_taken),2) AS average_delivery_time
FROM
    unit_delivery_time
GROUP BY
    rider_id,
    rider_name
ORDER BY
    average_delivery_time



/*Q11. Monthly Restaurant Growth Ratio
Question:
Calculate each restaurant's growth ratio based on the total number of delivered orders since its
joining.*/

WITH growth_ratio AS
(
    SELECT 
        r.restaurant_name,
        r.restaurant_id,
        TO_CHAR (o.order_date, 'mm-yy') AS months,
        COUNT(o.order_id) AS cr_month_orders,
        LAG(COUNT(o.order_id), 1) OVER(PARTITION BY r.restaurant_id ORDER BY TO_CHAR (o.order_date, 'mm-yy')) AS prev_month_orders
    FROM orders o 
    JOIN deliveries d 
        ON d.order_id = o.order_id
    RIGHT JOIN restaurants r 
        ON r.restaurant_id = o.restaurant_id
    WHERE d.delivery_status = 'Delivered'
    GROUP BY
        r.restaurant_name,
        r.restaurant_id,
        months
    ORDER BY
        r.restaurant_id,
        months
    )
SELECT 
    restaurant_id,
    restaurant_name,
    months,
    prev_month_orders,
    cr_month_orders,
    ROUND((cr_month_orders::numeric - prev_month_orders::numeric)/prev_month_orders::numeric * 100, 2) AS growth_ratio
FROM growth_ratio
WHERE growth_ratio IS NOT NULL

/*Q12. Customer Segmentation
Question:
Segment customers into 'Gold' or 'Silver' groups based on their total spending compared to the
average order value (AOV). If a customer's total spending exceeds the AOV, label them as
'Gold'; otherwise, label them as 'Silver'.
Return: The total number of orders and total revenue for each segment. */

WITH segment AS

(
    SELECT
        c.customer_id,
        c.customer_name,
        SUM(o.total_amount) AS total_revenue,
        COUNT(o.order_id) AS total_orders,
        CASE 
            WHEN SUM(o.total_amount) > (SELECT AVG(total_amount)FROM orders) THEN 'Gold' ELSE 'Silver' 
        END AS groupings
    FROM orders o 
    RIGHT JOIN customers c 
        ON c.customer_id = o.customer_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        c.customer_id,
        c.customer_name
    ORDER BY
        total_revenue DESC
)

SELECT
    groupings,
    SUM(total_revenue) AS revenue,
    SUM(total_orders)  AS orders
FROM    
    segment
GROUP BY
    groupings

    
/*Q13. Rider Monthly Earnings
Question:
Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.*/

WITH riders_monthly_earnings AS
(
    SELECT
        r.rider_id,
        r.rider_name, 
        EXTRACT (MONTH FROM o.order_date) AS months,
        EXTRACT (YEAR FROM o.order_date) AS years,
        SUM(o.total_amount) AS total_monthly_orders,
        RANK() OVER(PARTITION BY r.rider_id ORDER BY r.rider_id, r.rider_name)
    FROM orders o 
    JOIN deliveries d   
        ON o.order_id = d.order_id
    JOIN riders r 
        ON r.rider_id = d.rider_id
    WHERE o.order_status = 'Completed'
    GROUP BY
        r.rider_id,
        r.rider_name,
        months,
        years
    ORDER BY
        r.rider_id,
        years,
        months
)
SELECT
    rider_id,
    rider_name,
    months,
    years,
    ROUND(8/100::numeric * total_monthly_orders::numeric,2) AS monthly_earnings
FROM riders_monthly_earnings

/*Q14. Rider Ratings Analysis
Question:
Find the number of 5-star, 4-star, and 3-star ratings each rider has.
Riders receive ratings based on delivery time:
● 5-star: Delivered in less than 15 minutes
● 4-star: Delivered between 15 and 20 minutes
● 3-star: Delivered after 20 minutes*/

WITH delivered_time AS
(
    SELECT
        r.rider_id,
        r.rider_name,
        o.order_id,
        o.order_time,
        d.delivery_time,
        EXTRACT(EPOCH FROM (d.delivery_time - o.order_time + 
        CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 day'
        ELSE INTERVAL '0 day' END))/60 AS time_taken
    FROM riders r
    JOIN deliveries d
        ON r.rider_id = d.rider_id
    JOIN orders o 
        ON o.order_id = d.order_id
    ORDER BY
        o.order_id
),

ratings AS
(
    SELECT
        rider_id,
        rider_name,
        order_id,
        order_time,
        delivery_time,
        time_taken,
        CASE 
                WHEN time_taken < 15 THEN '5-star'
                WHEN time_taken BETWEEN 15 AND 20 THEN '4-star'
                ELSE '3-star'
        END AS star_rating
    FROM 
        delivered_time
)
SELECT
    rider_id,
    rider_name,
    star_rating,
    COUNT(star_rating)
FROM ratings
GROUP BY
    rider_id,
    rider_name,
    star_rating
ORDER BY
    rider_id,
    star_rating DESC

/*Q15. Order Frequency by Day
Question:
Analyze order frequency per day of the week and identify the peak day for each restaurant.*/




/*Q16. Customer Lifetime Value (CLV)
Question:
Calculate the total revenue generated by each customer over all their orders.*/

SELECT
    c.customer_id,
    c.customer_name,
    SUM(o.total_amount) AS total_revenue
FROM orders o
JOIN customers c 
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY 
   total_revenue DESC



SELECT * FROM customers