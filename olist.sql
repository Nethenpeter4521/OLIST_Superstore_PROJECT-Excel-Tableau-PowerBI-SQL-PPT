use olist_db;
select * from olist_orders_dataset;
select * from olist_customers_dataset;
select * from olist_order_reviews_dataset;
select * from olist_order_payments_dataset;
select * from olist_order_items_dataset;
select * from olist_products_dataset;
select * from olist_sellers_dataset;
select * from product_category_name_translation;

## 1) Weekday Vs Weekend (order_purchase_timestamp) Payment Statistics */
Select Week_Name as Weekname,
round(sum(payment_value),0) as total_sales
from olist_orders_dataset as o inner join olist_order_payments_dataset as p
on o.order_id = p.order_id
where order_purchase_timestamp is not null
group by Weekname;

## 2) Number of Orders with review score 5 and payment type as credit card. */
select review_score as review_score,
count(distinct o.order_id) as number_of_Orders,
p.payment_type as payment_mode 
from olist_orders_dataset as o inner join olist_order_reviews_dataset as r
on o.order_id = r.order_id
inner join olist_order_payments_dataset as p
on o.order_id = p.order_id
where review_score = 5 and payment_type = 'credit_card';

## 3)Average number of days taken for order_delivered_customer_date for pet_shop */ 
select round(avg(o.shipping_days),0) as avg_number_of_days
from 
(
select *, DATEDIFF(
STR_TO_DATE(order_delivered_customer_date, '%d-%m-%Y'),
STR_TO_DATE(order_purchase_timestamp, '%d-%m-%Y')
) as shipping_days from olist_orders_dataset
 where order_purchase_timestamp != "" and order_delivered_customer_date != ""
 ) 
as o inner join olist_order_items_dataset oid
on o.order_id = oid.order_id 
inner join olist_products_dataset as opd on oid.product_id = opd.product_id
where opd.Product_Category = "Pet_Shop";

## 4) Average price and payment values from customers of sao paulo city */
select concat('R$',format(avg(price),2)) as avg_price,concat('R$',format(avg(payment_value),2)) as avg_payment_value from olist_order_payments_dataset 
inner join olist_order_items_dataset 
on olist_order_payments_dataset.order_id = olist_order_items_dataset.order_id
inner join olist_orders_dataset 
on olist_order_items_dataset.order_id = olist_orders_dataset.order_id
inner join olist_customers_dataset 
on olist_orders_dataset.customer_id = olist_customers_dataset.customer_id 
where customer_city="sao paulo";

## 5) Relationship between shipping days (order_delivered_customer_date - order_purchase_timestamp) Vs review scores. */
select ord.review_score,
round(avg(DATEDIFF(STR_TO_DATE(o.order_delivered_customer_date, '%d-%m-%Y'), STR_TO_DATE(o.order_purchase_timestamp, '%d-%m-%Y'))),0)
as shipping_days
from olist_orders_dataset as o
inner join olist_order_reviews_dataset as ord
on o.order_id = ord.order_id
where ord.review_score is not null
group by ord.review_score 
order by shipping_days;

## 6) Total revenue, orders, items sold, and customers over time
SELECT 
	SUM(COALESCE(payment_value, (price + freight_value)))AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM olist_orders_dataset AS o
JOIN olist_order_payments_dataset AS op ON o.order_id = op.order_id
JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id;

## 7) How does delivery timeliness impact revenue, orders, items sold, and customers
SELECT 
	CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 'On-time Delivery'
		ELSE 'Late Delivery' END AS delivery_timeliness,
	SUM(COALESCE(payment_value, (price + freight_value))) AS total_revenue,
	COUNT(DISTINCT o.order_id) AS total_order,
	COUNT(product_id) AS total_items_sold,
	COUNT(DISTINCT customer_unique_id) AS total_customer
FROM olist_orders_dataset AS o
JOIN olist_order_payments_dataset AS op ON o.order_id = op.order_id
JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id
GROUP BY 1;


