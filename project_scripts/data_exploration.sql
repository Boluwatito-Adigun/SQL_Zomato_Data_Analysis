SELECT 
    count(*)
FROM 
    customers
WHERE
    customer_name IS NULL
    OR
    reg_date IS NULL;

SELECT 
    count(*)
FROM 
    restaurants
WHERE
    restaurant_name IS NULL
    OR
    opening_hours IS NULL
    OR
    city IS NULL;


SELECT 
    count(*)
FROM 
    orders
WHERE
    order_item IS NULL
    OR
    order_date IS NULL
    OR
    order_time IS NULL
    OR
    order_status IS NULL
    OR
    total_amount IS NULL;
    

SELECT 
    *
FROM
    deliveries
WHERE
    delivery_time IS NULL
    OR
    delivery_status IS NULL;


DELETE FROM
    deliveries
WHERE
    delivery_time IS NULL
    OR
    delivery_status IS NULL;
   

SELECT 
    *
FROM
    riders
WHERE
    rider_name IS NULL
    OR
    sign_up IS NULL;