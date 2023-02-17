-- null values and data types in the customer_orders and runner_orders tables!

-- A. Pizza Metrics
-- How many pizzas were ordered?
-- How many unique customer orders were made?
-- How many successful orders were delivered by each runner?
-- How many of each type of pizza was delivered?
-- How many Vegetarian and Meatlovers were ordered by each customer?
-- What was the maximum number of pizzas delivered in a single order?
-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
-- How many pizzas were delivered that had both exclusions and extras?
-- What was the total volume of pizzas ordered for each hour of the day?
-- What was the volume of orders for each day of the week?

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
SET pickup_time  = '2000-01-01 18:15:34' 
WHERE pickup_time ='null' OR pickup_time = '' OR pickup_time IS NULL

UPDATE runner_orders
SET distance  = 0 
WHERE distance ='null' OR distance = '' OR distance IS NULL;

UPDATE runner_orders
SET duration  = 0 
WHERE duration ='null' OR duration = '' OR duration IS NULL;

UPDATE runner_orders 
SET distance=REPLACE(distance,'km','') 
WHERE distance LIKE '%km';

UPDATE runner_orders 
SET duration=REPLACE(duration,'minute','') 
WHERE duration LIKE '% minute'; 

UPDATE runner_orders 
SET duration=REPLACE(duration,'mins','') 
WHERE duration LIKE '%mins';

UPDATE runner_orders 
SET duration=REPLACE(duration,'minutes','') 
WHERE duration LIKE '%minutes';

UPDATE runner_orders 
SET cancellation = 1 
WHERE cancellation LIKE '%Restaurant%'

UPDATE runner_orders 
SET cancellation = 2 
WHERE cancellation LIKE '%Customer%'

UPDATE runner_orders
SET cancellation  = 0 
WHERE cancellation ='null' OR cancellation = '' OR cancellation IS NULL;

UPDATE runner_orders 
SET distance = CAST(distance AS DECIMAL(10,2));

UPDATE runner_orders 
SET cancellation=CAST(cancellation AS UNSIGNED INTEGER)

UPDATE runner_orders 
SET duration = CAST(duration AS UNSIGNED INTEGER)

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




--=========================Runner and Customer Experience=====================================================

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- 4. What was the average distance travelled for each customer?
-- 5. What was the difference between the longest and shortest delivery times for all orders?
-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- 7. What is the successful delivery percentage for each runner?

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

-- If the week starts in a different day than sunday use 1
SELECT 
	runner_id,
	registration_date ,
	WEEK(registration_date, 1) 
FROM runners r 


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
-- change 0 for oldest date in sql and select > than
-- compare cus ord order time to run ord pick time


-- study TIMESTAMPDIFF
CREATE TEMPORARY TABLE hd_pickup
(SELECT 
	DISTINCT (order_id),
	ro.runner_id,
	ROUND(TIMESTAMPDIFF(MINUTE, order_time, ro.pickup_time),2) as  pick_hd
FROM  customer_orders co 
INNER JOIN runner_orders ro USING (order_id)
WHERE distance > 0) 


select ROUND(avg(pick_hd),2)  from hd_pickup group by runner_id



-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- count by order id 
-- mean by each number 

-- solving with temporary table 
CREATE TEMPORARY TABLE pizza_toprep(
SELECT 
	co.order_id,
	ROUND(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time),2) as pick_hd
FROM customer_orders co
INNER JOIN runner_orders ro USING (order_id)
WHERE ro.duration > 0
)

SELECT 
order_id,
COUNT(order_id) as qtd_pizza_by_order,
AVG(pick_hd) as avg_prep_by_qtd
FROM pizza_toprep
GROUP BY order_id

-- solving with subquery

SELECT
order_id,
COUNT(order_id) as qtd_pizza_by_order,
AVG(pick_hd) as avg_prep_by_qtd
FROM(SELECT 
	co.order_id,
	ROUND(TIMESTAMPDIFF(MINUTE, co.order_time, ro.pickup_time),2) as pick_hd
FROM customer_orders co
INNER JOIN runner_orders ro USING (order_id)
WHERE ro.duration > 0) AS pizza_toprep1
GROUP BY order_id

-- 4. What was the average distance travelled for each customer?

SELECT 
customer_id,
ROUND(AVG(distance), 2) AS avg_dist_per_cust
FROM (SELECT 
	co.customer_id,
	ro.distance
FROM runner_orders ro 
INNER JOIN customer_orders co USING (order_id)
WHERE ro.cancellation = 0) AS all_cust
GROUP BY 1




-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT 
MIN(duration),
MAX(duration),
(MAX(duration) - MIN(duration)) AS max_difference
FROM  runner_orders ro 
WHERE duration > 0



-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
-- To convert minutes to hours, divide the minutes by 60. So the total time taken is 32/60 = 0.53 hours.
-- Only the duration and the distance been the same the avg speed is 60km/h
SELECT 
runner_id,
distance,
duration,
ROUND((duration/60),2) AS duration_minutes,
ROUND((distance/(duration/60)),2) AS avg_speed
FROM  runner_orders 
WHERE cancellation = 0
ORDER BY runner_id ASC

-- SELECT 
-- runner_id,
-- ROUND((total_duration/total_distance),2) AS avg_speed
-- FROM  (SELECT
-- runner_id,
-- SUM(duration) AS total_duration,
-- SUM(distance) AS total_distance
-- FROM  runner_orders ro 
-- WHERE duration > 0 
-- ) AS calc



-- 7. What is the successful delivery percentage for each runner?
SELECT 
sub_all.runner_id,
(sub_del.success_deliveries/sub_all.all_deliveries)*100 AS percentge_success_deliveries_by_runner
FROM 
	(SELECT 
	runner_id,
	COUNT(order_id) AS all_deliveries
	FROM  runner_orders ro 
	
	GROUP BY 1) AS sub_all
JOIN 
	(SELECT 
	runner_id,
	COUNT(order_id) AS success_deliveries
	FROM  runner_orders ro 
	WHERE cancellation < 1
	GROUP BY 1) AS sub_del
ON sub_del.runner_id = sub_all.runner_id







--=========================Ingredient Optimisation=====================================================

-- 1. What are the standard ingredients for each pizza?
-- 2. What was the most commonly added extra?
-- 3. What was the most common exclusion?
-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- 		Meat Lovers
-- 		Meat Lovers - Exclude Beef
-- 		Meat Lovers - Extra Bacon
-- 		Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- 		For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

--=====================================================================================
CREATE TEMPORARY TABLE row_split_customer_orders_temp AS
SELECT t.row_num,
       t.order_id,
       t.customer_id,
       t.pizza_id,
       trim(j1.exclusions) AS exclusions,
       trim(j2.extras) AS extras,
       t.order_time
FROM
  (SELECT *,
          row_number() over() AS row_num
   FROM customer_orders) t
INNER JOIN json_table(trim(replace(json_array(t.exclusions), ',', '","')),
                      '$[*]' columns (exclusions varchar(50) PATH '$')) j1
INNER JOIN json_table(trim(replace(json_array(t.extras), ',', '","')),
                      '$[*]' columns (extras varchar(50) PATH '$')) j2 ;


SELECT *
FROM row_split_customer_orders_temp;


--=====================================================================================
CREATE
TEMPORARY TABLE row_split_pizza_recipes_temp AS
SELECT t.pizza_id,
       trim(j.topping) AS topping_id
FROM pizza_recipes t
JOIN json_table(trim(replace(json_array(t.toppings), ',', '","')),
                '$[*]' columns (topping varchar(50) PATH '$')) j ;


SELECT *
FROM row_split_pizza_recipes_temp;

-- =====================================================================================

CREATE
TEMPORARY TABLE standard_ingredients AS
SELECT pizza_id,
       pizza_name,
       group_concat(DISTINCT topping_name) 'standard_ingredients'
FROM row_split_pizza_recipes_temp
INNER JOIN pizza_names USING (pizza_id)
INNER JOIN pizza_toppings USING (topping_id)
GROUP BY 1, 2
ORDER BY pizza_id;

SELECT *
FROM standard_ingredients;





-- 1. What are the standard ingredients for each pizza?
SELECT * FROM standard_ingredients;

-- 2. What was the most commonly added extra?
CREATE
TEMPORARY TABLE most_added_top0 AS 
SELECT 
	pizza_id,
	extras,
	COUNT(extras) AS count_most_added_nr
FROM row_split_customer_orders_temp
WHERE extras != '0'
GROUP BY 1,2

SELECT 
	pizza_id,
	extras,
	count_most_added_nr,
	SUBSTRING_INDEX(SUBSTRING_INDEX(standard_ingredients, ',', 1), ',', -1)  AS MOST_ADDED_TOP_NAME
FROM standard_ingredients
INNER JOIN most_added_top0 mt USING(pizza_id)
LIMIT 2

-- 3. What was the most common exclusion?

-- trim option
-- SELECT trim(extras) AS extra_topping
--           count(*) AS purchase_counts
--    FROM row_split_customer_orders_temp
--    WHERE extras != '0'
--    GROUP BY extras
   
CREATE 
TEMPORARY TABLE most_excluded_top AS 
SELECT  
	pizza_id,
	exclusions,
	COUNT(exclusions) AS most_excluded_top_nr
FROM row_split_customer_orders_temp
WHERE exclusions != 0
GROUP BY 1,2

SELECT 
	pizza_id,
	exclusions,
	most_excluded_top_nr,
	SUBSTRING_INDEX(SUBSTRING_INDEX(standard_ingredients, ',', 4), ',', -1) AS MOST_EXCLUDED_TOP_NAME
FROM standard_ingredients
INNER JOIN most_excluded_top USING(pizza_id)
LIMIT 2

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
-- 		Meat Lovers
-- 		Meat Lovers - Exclude Beef
-- 		Meat Lovers - Extra Bacon
-- 		Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers


SELECT 
	CASE 
		WHEN exclusions = 0 AND pizza_id = 1 THEN 'Meat Lovers'
		WHEN exclusions = 1 AND pizza_id = 1 THEN 'Meat Lovers - Exclude Beef'
		WHEN extras = 1 AND pizza_id = 1 THEN 'Meat Lovers - Extra Bacon'
		ELSE 'vegetarian'
	END AS customized_orders	
FROM row_split_customer_orders_temp;



-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
-- 		For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?






SELECT * FROM standard_ingredients;

SELECT * FROM row_split_pizza_recipes_temp;

SELECT * FROM row_split_customer_orders_temp;

SELECT * FROM  customer_orders co 

SELECT * FROM  pizza_names pn 

SELECT * FROM  pizza_recipes pr  

SELECT * FROM  pizza_toppings pt 

SELECT * FROM  runner_orders ro 

SELECT * FROM  runners r 
