create database doc;
-- SELECT * FROM deep.`pizzas[1]`;-- 
-- SELECT * FROM deep.`pizza_types[1]`; 
-- create table orders(
-- order_id int not null,
-- order_date date not null,
-- order_time time not null,
-- primary key(order_id));
 

 create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

select * from order_details;

-- 1.Retrieve the total number of order placed

select count(order_id) as total_orders from orders;

-- 2.Calculate the total revenue generated from pizza sales

-- select 
-- round(sum(order_details.quantity * `pizzas[1]`.price),2) as total_sales from order_details 
-- join `pizzas[1]` on `pizzas[1]`.pizza_id=order_details.pizza_id

-- 3.Identify the highest priced pizza 

-- select `pizza_types[1]`.name,`pizzas[1]`.price from `pizza_types[1]` join `pizzas[1]` on 
-- `pizza_types[1]`.pizza_type_id=`pizzas[1]`.pizza_type_id
-- order by `pizzas[1]`.price desc limit 1;

-- 4.identify the most common pizza size ordered

select `pizzas[1]`.size,count(order_details.order_details_id) as order_count
from `pizzas[1]` join order_details on `pizzas[1]`.pizza_id=order_details.pizza_id
group by `pizzas[1]`.size
order by order_count desc;

-- 5.list the top 5 most ordered pizza types along with  their quantities 

SELECT `pizza_types[1]`.name, 
       SUM(order_details.quantity) AS quantity  
FROM `pizza_types[1]`
JOIN `pizzas[1]` ON `pizza_types[1]`.pizza_type_id = `pizzas[1]`.pizza_type_id
JOIN order_details ON order_details.pizza_id = `pizzas[1]`.pizza_id
GROUP BY `pizza_types[1]`.name 
ORDER BY quantity DESC  
LIMIT 5;

-- Join the necessary tables to find the total quantity of each pizza category ordered 

select `pizza_types[1]`.category,
sum(order_details.quantity)as quantity
from  `pizza_types[1]` join `pizzas[1]`
on `pizza_types[1]`.pizza_type_id=`pizzas[1]`.pizza_type_id
join order_details
on order_details.order_details_id=`pizzas[1]`.pizza_type_id
group by `pizza_types[1]`.category order by quantity desc ;

-- Determine the distribution of orders by hour of the day.

select hour(order_time),count(order_id)from orders
group by hour(order_time);

-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) from `pizza_types[1]`
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

select round(avg(quantity),0) as avg_pizza_ordered_per_day from
(select orders.order_date,sum(order_details.quantity) as quantity from orders join order_details on orders.order_id=order_details.order_id
group by orders.order_date) as order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select `pizza_types[1]`.name,
sum(order_details.quantity*`pizzas[1]`.price) as revenue
from `pizza_types[1]` join `pizzas[1]`
 on `pizzas[1]`.pizza_type_id=`pizza_types[1]`.pizza_type_id
join order_details
on order_details.pizza_id=`pizzas[1]`.pizza_id
group by `pizza_types[1]`.name order by revenue desc limit 3;

-- Calculate the percentage contribution of each pizza type to total revenue.
select  `pizza_types[1]`.category,
round(sum(order_details.quantity*`pizzas[1]`.price)/(select round(sum(order_details.quantity*`pizzas[1]`.price),2)as total
from order_details join `pizzas[1]` on `pizzas[1]`.pizza_id=order_details.pizza_id)*100,2)as revenue
from `pizza_types[1]` join `pizzas[1]`on
 `pizzas[1]`.pizza_type_id=`pizza_types[1]`.pizza_type_id
join order_details
on order_details.pizza_id=`pizzas[1]`.pizza_id
group by `pizza_types[1]`.category order by revenue desc;

-- Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over(order by order_date) as cum_revenue from
(select orders.order_date, sum(order_details.quantity * `pizzas[1]`.price) as revenue
from order_details join `pizzas[1]`on order_details.pizza_id=`pizzas[1]`.pizza_id
join orders
on orders.order_id=order_details_id group by orders.order_date)as sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name,revenue,rank() over(partition by category order by revenue desc) as rn from (
select `pizza_types[1]`.category, `pizza_types[1]`.name,sum((order_details.quantity)*`pizzas[1]`.price) as revenue 
from `pizza_types[1]` join `pizzas[1]` on `pizza_types[1]`.pizza_type_id=`pizzas[1]`.pizza_type_id
join order_details on order_details.pizza_id=`pizzas[1]`.pizza_id 
group by `pizza_types[1]`.category, `pizza_types[1]`.name) as a;


