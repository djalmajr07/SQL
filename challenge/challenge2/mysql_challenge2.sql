--null values and data types in the customer_orders and runner_orders tables!
--
--A. Pizza Metrics
--How many pizzas were ordered?
--How many unique customer orders were made?
--How many successful orders were delivered by each runner?
--How many of each type of pizza was delivered?
--How many Vegetarian and Meatlovers were ordered by each customer?
--What was the maximum number of pizzas delivered in a single order?
--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
--How many pizzas were delivered that had both exclusions and extras?
--What was the total volume of pizzas ordered for each hour of the day?
--What was the volume of orders for each day of the week?

-- ============== Replace null in customer_orders ===============================
UPDATE customer_orders
SET exclusions = 0 
WHERE exclusions ='null' OR exclusions = '';

UPDATE customer_orders
SET extras = 0 
WHERE extras ='null' OR extras = '' OR extras IS NULL;
-- ==============================================================================

-- =============== Replace null in runner_orders ================================
UPDATE runner_orders
SET pickup_time  = 0 -- take care here due date = 0
WHERE pickup_time ='null' OR pickup_time = '' OR pickup_time ISNULL;

UPDATE runner_orders
SET distance  = 0 
WHERE distance ='null' OR distance = '' OR distance ISNULL;

UPDATE runner_orders
SET duration  = 0 
WHERE duration ='null' OR duration = '' OR duration ISNULL;

UPDATE runner_orders
SET cancellation  = 0 
WHERE cancellation ='null' OR cancellation = '' OR cancellation ISNULL;

UPDATE runner_orders 
SET distance=REPLACE(distance,'km','') WHERE distance LIKE '%km';

UPDATE runner_orders 
SET duration=REPLACE(duration,'minute','') WHERE duration LIKE '% minute' 

UPDATE runner_orders 
SET duration=REPLACE(duration,'mins','') WHERE duration LIKE '%mins';

UPDATE runner_orders 
SET duration=REPLACE(duration,'minutes','') WHERE duration LIKE '%minutes';

SELECT * FROM  runner_orders ro 
-- ================================Pizza Metrics===========================================


--1. How many pizzas were ordered?
SELECT COUNT(order_id) AS total_orders  FROM customer_orders co 


--2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) AS total_orders  FROM customer_orders co 


--3. How many successful orders were delivered by each runner?
SELECT 
	runner_id, 
	COUNT(order_id) AS pizza_delivered
FROM runner_orders ro 
WHERE distance NOT IN (0)
GROUP BY runner_id


--4. How many of each type of pizza was delivered?
SELECT 
	COUNT(ro.order_id) AS total_pizzas_delivered,
	pn.pizza_name
FROM customer_orders co 
LEFT JOIN runner_orders ro USING (order_id)
LEFT JOIN pizza_names pn USING(pizza_id)
WHERE ro.distance NOT IN (0)
GROUP BY pn.pizza_name


--5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
	customer_id,
	pizza_name, 
	COUNT(pn.pizza_name) AS quantity_by_user
FROM customer_orders co 
LEFT JOIN pizza_names pn USING(pizza_id)
GROUP BY customer_id, pizza_name


--6. What was the maximum number of pizzas delivered in a single order?
SELECT 
	order_id,
	COUNT(pizza_id) AS max_quantity_pizza_ordered,
	order_time
FROM customer_orders co 
LEFT JOIN runner_orders ro USING (order_id)
LEFT JOIN pizza_names pn USING(pizza_id)
WHERE ro.distance NOT IN (0)
GROUP BY order_id, order_time
ORDER BY max_quantity_pizza_ordered DESC
LIMIT 1


--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT 
	customer_id,
	SUM(CASE WHEN (exclusions > 0  OR extras > 0) THEN 1 ELSE 0 END) AS at_least_one_change,
	SUM(CASE WHEN (exclusions = 0 AND extras = 0) THEN 1 ELSE 0 END) AS no_change
FROM customer_orders co 
INNER JOIN runner_orders ro USING (order_id)
WHERE ro.distance NOT IN (0)
GROUP BY customer_id;


--8. How many pizzas were delivered that had both exclusions and extras?
SELECT 
	customer_id,
	SUM(CASE WHEN (exclusions > 0 AND extras > 0) THEN 1 ELSE 0 END) AS order_changed
FROM customer_orders co 
INNER JOIN runner_orders ro USING (order_id)
WHERE ro.distance NOT IN (0)
GROUP BY customer_id 
ORDER BY order_changed DESC 


--9. What was the total volume of pizzas ordered for each hour of the day?
SELECT STRFTIME('%Y-%m-%d %H', order_time) as hour,
       COUNT(*) as max_volume_of_order
FROM customer_orders co 
GROUP BY STRFTIME('%Y-%m-%d %H', order_time)
ORDER BY hour ASC


--10. What was the volume of orders for each day of the week?
SELECT STRFTIME('%Y-%m-%d', order_time) as day,
       COUNT(*) as max_volume_of_orders
FROM customer_orders co 
GROUP BY STRFTIME('%Y-%m-%d', order_time)

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456’


--=========================Runner and Customer Experience=====================================================

--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
--4. What was the average distance travelled for each customer?
--5. What was the difference between the longest and shortest delivery times for all orders?
--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
--7. What is the successful delivery percentage for each runner?



SELECT * FROM  customer_orders co 

SELECT * FROM  pizza_names pn 

SELECT * FROM  pizza_recipes pr  

SELECT * FROM  pizza_toppings pt 

SELECT * FROM  runner_orders ro 

SELECT * FROM  runners r 