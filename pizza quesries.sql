use Pizza_sales;
SHOW TABLES;

-- See structure of each table
DESCRIBE orders;
DESCRIBE order_details;
DESCRIBE pizzas;
DESCRIBE pizza_types;

-- Preview each table
SELECT * FROM orders LIMIT 10;
SELECT * FROM order_details LIMIT 10;
SELECT * FROM pizzas LIMIT 10;
SELECT * FROM pizza_types LIMIT 10;

-- Total number of orders
SELECT COUNT(*) AS total_orders FROM orders;

-- Total quantity of pizzas sold
SELECT SUM(quantity) AS total_pizzas_sold FROM order_details;


--  Total Revenue
SELECT ROUND(SUM(od.quantity * p.price), 2) AS total_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id;


-- Daily Revenue Trend
SELECT o.date, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY o.date
ORDER BY o.date;



-- Hourly Orders
SELECT HOUR(time) AS order_hour, COUNT(*) AS order_count
FROM orders
GROUP BY order_hour
ORDER BY order_hour;



-- Most Popular Pizzas (by Quantity Sold)
SELECT pt.name, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 10;


-- Most Profitable Pizzas (by Revenue)
SELECT p.size, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY revenue DESC;



-- Sales by Pizza Size
SELECT p.size, SUM(od.quantity) AS total_sold
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY total_sold DESC;


-- Sales by Category (Veggie, Meat, etc.)
SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;


-- Average Order Value (AOV)
SELECT ROUND(SUM(od.quantity * p.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id;



-- Top 3 Pizzas per Category
SELECT category, name, total_quantity FROM (
  SELECT 
    pt.category,
    pt.name,
    SUM(od.quantity) AS total_quantity,
    RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity) OVER (PARTITION BY pt.category, pt.name) DESC) AS rnk
  FROM order_details od
  JOIN pizzas p ON od.pizza_id = p.pizza_id
  JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
  GROUP BY pt.category, pt.name
) ranked
WHERE rnk <= 3;


-- Orders with More Than 3 Pizzas
SELECT od.order_id, SUM(od.quantity) AS total_pizzas
FROM order_details od
GROUP BY od.order_id
HAVING total_pizzas > 3;



-- Weekday Sales Performance
SELECT DAYNAME(o.date) AS weekday, COUNT(*) AS order_count
FROM orders o
GROUP BY weekday
ORDER BY FIELD(weekday, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');





-- Top 3 Pizzas per Category by Quantity
SELECT category, name, total_quantity
FROM (
  SELECT 
    category,
    name,
    total_quantity,
    RANK() OVER (PARTITION BY category ORDER BY total_quantity DESC) AS rnk
  FROM (
    SELECT 
      pt.category,
      pt.name,
      SUM(od.quantity) AS total_quantity
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY pt.category, pt.name
  ) AS aggregated
) AS ranked
WHERE rnk <= 3;



-- Total Revenue per Pizza Size
SELECT p.size, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY p.size
ORDER BY revenue DESC;




-- Pizza Types with the Highest Average Price
SELECT pt.name, AVG(p.price) AS avg_price
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY avg_price DESC
LIMIT 10;






-- Monthly Order Counts
SELECT MONTH(date) AS month, COUNT(*) AS order_count
FROM orders
GROUP BY MONTH(date)
ORDER BY month;


-- Revenue per Category
SELECT pt.category, ROUND(SUM(od.quantity * p.price), 2) AS category_revenue
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY category_revenue DESC;



-- Revenue per Day of the Week
SELECT DAYNAME(o.date) AS weekday, ROUND(SUM(od.quantity * p.price), 2) AS revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY weekday
ORDER BY FIELD(weekday, 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday');



-- Least Popular Pizzas (Bottom 5)
SELECT pt.name, SUM(od.quantity) AS total_sold
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_sold ASC
LIMIT 5;




-- Average Number of Pizzas per Order
SELECT ROUND(AVG(order_total), 2) AS avg_pizzas_per_order
FROM (
  SELECT order_id, SUM(quantity) AS order_total
  FROM order_details
  GROUP BY order_id
) AS sub;



-- Top Pizza per Day (Daily Bestseller)
SELECT date, name, total_quantity FROM (
  SELECT 
    o.date,
    pt.name,
    SUM(od.quantity) AS total_quantity,
    RANK() OVER (PARTITION BY o.date ORDER BY SUM(od.quantity) DESC) AS rnk
  FROM orders o
  JOIN order_details od ON o.order_id = od.order_id
  JOIN pizzas p ON od.pizza_id = p.pizza_id
  JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
  GROUP BY o.date, pt.name
) ranked
WHERE rnk = 1;





-- Orders That Contained More Than One Pizza Type
SELECT order_id
FROM order_details
GROUP BY order_id
HAVING COUNT(DISTINCT pizza_id) > 1;




-- Top 3 Pizza Sizes per Category
SELECT category, size, total_quantity FROM (
  SELECT 
    pt.category,
    p.size,
    SUM(od.quantity) AS total_quantity,
    RANK() OVER (PARTITION BY pt.category ORDER BY SUM(od.quantity) DESC) AS rnk
  FROM order_details od
  JOIN pizzas p ON od.pizza_id = p.pizza_id
  JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
  GROUP BY pt.category, p.size
) ranked
WHERE rnk <= 3;









