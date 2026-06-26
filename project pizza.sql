create table pizzas (pizza_id varchar(50),  pizza_type_id varchar(50), size_ varchar(50), price numeric(5,2));

create table pizza_types_ (pizza_type_id	varchar(50),
name	varchar(50)	,
category	varchar(50)	,
ingredients	text	
		);

create table order_detail (order_details_id numeric(5),order_id numeric(5), pizza_id varchar(50), quantity numeric(5)
)

create table orders(
order_id	numeric(5),
date	date,
time	time)

select * from pizzas;
select * from  pizza_types_;
select * from order_detail;
select * from orders;


-- Retrieve the total number of orders placed.


SELECT
	COUNT(ORDER_ID) AS NO_OF_ORDERS
FROM
	ORDERS;


	
	-- Calculate the total revenue generated from pizza sales.

SELECT
	SUM(OD.QUANTITY * P.PRICE) AS TOTAL_REVENUE
FROM
	PIZZAS P
	JOIN ORDER_DETAIL OD ON P.PIZZA_ID = OD.PIZZA_ID;


-- Identify the highest-priced pizza.

SELECT
	P.NAME,
	PI.PRICE
FROM
	PIZZA_TYPES_ P
	JOIN PIZZAS PI ON P.PIZZA_TYPE_ID = PI.PIZZA_TYPE_ID
ORDER BY
	PI.PRICE DESC
LIMIT
	1;

-- Identify the most common pizza size ordered.

select pi.size_ , sum(od.quantity) total_quantity  from pizzas pi
join order_detail od
on pi.pizza_id = od.pizza_id
group by pi.size_
order by  sum(od.quantity) desc
;


-- List the top 5 most ordered pizza types along with their quantities.

SELECT
    pt.name,
    SUM(od.quantity) AS total_quantity
FROM order_detail od
JOIN pizzas p
    ON od.pizza_id = p.pizza_id
JOIN pizza_types_ pt
    ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


Intermediate:
select * from pizzas;
select * from  pizza_types_;
select * from order_detail;
select * from orders;
-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT
	PT.CATEGORY,
	SUM(OD.QUANTITY) AS TOTAL_QTY
FROM
	PIZZA_TYPES_ PT
	JOIN PIZZAS PI ON PI.PIZZA_TYPE_ID = PT.PIZZA_TYPE_ID
	JOIN ORDER_DETAIL OD ON PI.PIZZA_ID = OD.PIZZA_ID
GROUP BY
	PT.CATEGORY
ORDER BY
	SUM(OD.QUANTITY) DESC;

-- Determine the distribution of ordersby hour of the day.

SELECT
    EXTRACT(HOUR FROM o.time) AS hour_,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
GROUP BY EXTRACT(HOUR FROM o.time)
ORDER BY hour_;


-- Join relevant tables to find the category-wise distribution of pizzas.
select category , count(name) category_wise_distribution from pizza_types_
group by category
order by count(name) desc;

-- Group the orders by date and calculate the average number of pizzas ordered per day.
WITH daily_sales AS (
    SELECT 
        o.date,
        SUM(od.quantity) AS pizzas_per_day
    FROM orders o
    JOIN order_detail od
        ON o.order_id = od.order_id
    GROUP BY o.date
)
SELECT 
    ROUND(AVG(pizzas_per_day), 2) AS avg_pizzas_per_day
FROM daily_sales;
-- Determine the top 3 most ordered pizza types based on revenue.
WITH total_revenue AS (
    SELECT 
        pt.name AS pizza_type,
        SUM(pi.price * od.quantity) AS total_revenue
    FROM pizzas pi
    JOIN pizza_types_ pt
        ON pi.pizza_type_id = pt.pizza_type_id
    JOIN order_detail od
        ON pi.pizza_id = od.pizza_id
    GROUP BY pt.name
)
SELECT *
FROM total_revenue
ORDER BY total_revenue DESC
LIMIT 3;



:
-- Calculate the percentage contribution of each pizza type to total revenue.


WITH revenue_per_type AS (
    SELECT 
        pt.name AS pizza_type,
        SUM(pi.price * od.quantity) AS revenue
    FROM pizzas pi
    JOIN pizza_types_ pt
        ON pi.pizza_type_id = pt.pizza_type_id
    JOIN order_detail od
        ON pi.pizza_id = od.pizza_id
    GROUP BY pt.name
)
SELECT 
    pizza_type,
    revenue,
    ROUND(
        100.0 * revenue / SUM(revenue) OVER(),
        2
    ) AS revenue_percentage
FROM revenue_per_type
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time.
WITH daily_revenue AS (
    SELECT 
        o.date,
        SUM(pi.price * od.quantity) AS revenue
    FROM orders o
    JOIN order_detail od
        ON o.order_id = od.order_id
    JOIN pizzas pi
        ON od.pizza_id = pi.pizza_id
    GROUP BY o.date
)
SELECT 
    date,
    revenue,
    SUM(revenue) OVER (ORDER BY date) AS cumulative_revenue
FROM daily_revenue
ORDER BY date;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
WITH revenue_data AS (
    SELECT 
        pt.category,
        pt.name AS pizza_type,
        SUM(pi.price * od.quantity) AS revenue
    FROM pizzas pi
    JOIN pizza_types_ pt
        ON pi.pizza_type_id = pt.pizza_type_id
    JOIN order_detail od
        ON pi.pizza_id = od.pizza_id
    GROUP BY pt.category, pt.name
),
ranked_data AS (
    SELECT *,
           RANK() OVER (
               PARTITION BY category 
               ORDER BY revenue DESC
           ) AS rnk
    FROM revenue_data
)
SELECT 
    category,
    pizza_type,
    revenue
FROM ranked_data
WHERE rnk <= 3
ORDER BY category, revenue DESC;





