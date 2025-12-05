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
