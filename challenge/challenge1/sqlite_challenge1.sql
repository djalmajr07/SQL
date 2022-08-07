/* -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?
-- 2. How many days has each customer visited the restaurant?
-- 3. What was the first item from the menu purchased by each customer?
-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
-- 6. Which item was purchased first by the customer after they became a member?
-- 7. Which item was purchased just before the customer became a member?
-- 8. What is the total items and amount spent for each member before they became a member?
-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
	s.customer_id,
	SUM(m.price) AS amount_spent
FROM sales s
INNER JOIN menu m USING (product_id )
GROUP BY s.customer_id
	

-- 2. How many days has each customer visited the restaurant?
SELECT 
	customer_id,
	COUNT(DISTINCT order_date) 
FROM sales s 
GROUP BY customer_id 


-- 3. What was the first item from the menu purchased by each customer?

--this appproach solves the question but what if the customers had their first purchase
--in diffetent days ?
SELECT 
	s.customer_id,
	s.order_date,
	MIN(order_date) AS first_purchase,
	m.product_name 
FROM sales s 
LEFT JOIN menu m USING (product_id)
GROUP BY customer_id





select * from sales s 

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

-- What is the most purchased item on the menu
SELECT 	product_id, COUNT(product_id) AS most_pop FROM sales s GROUP BY product_id  ORDER BY most_pop DESC

-- how many times was it purchased by all customers
SELECT 
	s.customer_id,
	m.product_name, 
	COUNT(product_id) AS most_purchased_item
FROM sales s 
LEFT JOIN menu m USING (product_id)
GROUP BY s.customer_id, m.product_name 
ORDER BY most_purchased_item DESC 

-- 5. Which item was the most popular for each customer? A: For User A and B is Ramen, otherwise user B ordered the same quantity for each item.
SELECT 
	s.customer_id,
	m.product_name, 
	COUNT(product_id) AS most_purchased_item
FROM sales s 
LEFT JOIN menu m USING (product_id)
GROUP BY s.customer_id, m.product_name 
ORDER BY most_purchased_item DESC 


-- 6. Which item was purchased first by the customer after they became a member?
SELECT 
	m.customer_id,
	s.order_date,
	m2.product_name
FROM members m  
LEFT JOIN sales s USING (customer_id)
LEFT JOIN menu m2 USING (product_id)
WHERE s.order_date >= m.join_date 
GROUP BY s.customer_id


-- 7. Which item was purchased just before the customer became a member?
SELECT 
	customer_id,
	m2.product_name,
	s.order_date 
FROM members m  
LEFT JOIN sales s USING (customer_id)
LEFT JOIN menu m2 USING (product_id)
WHERE s.order_date < m.join_date 
GROUP BY s.customer_id, product_name, s.order_date 


-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
	customer_id,
	COUNT(product_name) AS total_items,
	SUM(m2.price) AS amount_spent
FROM members m  
LEFT JOIN sales s USING (customer_id)
LEFT JOIN menu m2 USING (product_id)
WHERE s.order_date < m.join_date 
GROUP BY s.customer_id 


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
CREATE TEMPORARY TABLE promo_1 AS 
SELECT
	*,
	CASE WHEN product_id = 1 THEN price * 2 
	ELSE price 
	END AS points
FROM menu m2
 
SELECT 
	s.customer_id, 
	SUM(p.points) AS score
FROM promo_1 AS p  
JOIN sales s USING (product_id)
GROUP BY s.customer_id 


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi
-- how many points do customer A and B have at the end of January?
CREATE TEMPORARY TABLE member_promo_1 AS 
SELECT
	*,
	CASE WHEN product_id IN (1,2,3) THEN price * 2 
	END AS member_points
FROM menu m2

SELECT 
	s.customer_id,
	SUM(p.member_points) AS score
FROM member_promo_1 AS p  
JOIN sales s USING (product_id)
JOIN members m USING (customer_id)
WHERE s.order_date >= m.join_date AND s.order_date < '2021-01-31'
GROUP BY s.customer_id 

-- Rank All The Things

SELECT 
	s.customer_id,
	order_date,
	m.product_name,
	CASE 
	WHEN (customer_id = "A" AND m.product_name = "ramen") THEN 1
	WHEN (customer_id = "A" AND m.product_name = "curry") THEN 2
	WHEN (customer_id = "B" AND m.product_name = "sushi") THEN 1
	WHEN (customer_id = "B" AND m.product_name = "ramen") THEN 2
	END AS "ranking",
	m.price,
	CASE WHEN (s.customer_id IN ("A", "B") AND s.order_date >= "2021-01-07") OR (s.customer_id IN ("A", "B") AND s.order_date >= "2021-01-11") THEN "YES"
	ELSE "NOT YET"
	END AS "currently_member"
FROM sales s 
LEFT JOIN menu m USING (product_id)






--CREATE TEMPORARY TABLE ranking AS
SELECT 
	s.customer_id,
	m.product_name,
	order_date,
	CASE 
	WHEN (customer_id = "A" AND m.product_name = "ramen") THEN 1
	WHEN (customer_id = "A" AND m.product_name = "curry") THEN 2
	WHEN (customer_id = "B" AND m.product_name = "sushi") THEN 1
	WHEN (customer_id = "B" AND m.product_name = "ramen") THEN 2
	END AS "ranking"
FROM sales s 
LEFT JOIN menu m USING (product_id)
WHERE (customer_id = "A" AND order_date >= "2021-01-07") OR  (customer_id = "B" AND order_date >= "2021-01-11") OR (customer_id = "C")
GROUP BY s.customer_id, m.product_name 
ORDER BY customer_id ASC 


--
--SELECT
--	s.customer_id ,
--	m.product_name ,
--	RANK () OVER ( 
--		ORDER BY m.product_name  
--	) ValRank
--FROM sales s 
--LEFT JOIN menu m USING (product_id)


--CREATE TEMPORARY TABLE ranking_1 AS
SELECT 
  customer_id ,
  order_date ,
  m.product_name  ,
  RANK() OVER (PARTITION BY customer_id
                    ORDER BY m.product_name DESC
                    ) AS ranking
FROM sales s 
LEFT JOIN menu m USING (product_id)
WHERE (customer_id = "A" AND order_date >= "2021-01-07") OR  (customer_id = "B" AND order_date >= "2021-01-11") OR (customer_id = "C")


--select *from sales s 
--SELECT 
--	s.customer_id,
--	m.product_name, 
--	COUNT(product_id) AS most_purchased_item
--FROM sales s 
--LEFT JOIN menu m USING (product_id)
--WHERE 
--GROUP BY s.customer_id, m.product_name 
--ORDER BY most_purchased_item DESC 









SELECT 
	s.customer_id as ID
  	,(SUM(m.price)*20) As Total_points
FROM sales s
INNER JOIN menu m
    ON s.product_id  = m.product_id
INNER JOIN members mem
     ON s.customer_id = mem.customer_id
WHERE s.order_date >= mem.join_date AND s.order_date BETWEEN '2021-01-01' AND '2021-01-31'
GROUP BY  ID






















