use instacart_db;

-- ==========================================================
-- Category 1: Customer Behavior & Segmentation (5 questions)
-- ==========================================================
-- Q. 1- Har customer ka total order count, aur unhe engagement tiers (High/Medium/Low) mein NTILE() se segment karo.
select
	user_id,
	total_order_count,
	case 
		when buckets = 1 then 'High'
		when buckets = 2 then 'Medium'
		else 'Low'
	end as segment
from(
	select
		user_id,
		total_order_count,
		ntile(3) over(order by total_order_count desc) as buckets
	from
	(
		select
			user_id,
			COUNT(*) as total_order_count
		from orders 
		group by user_id
	)t
)x 
order by total_order_count desc;

-- Q. 2- Kaunse customers ka reorder rate time ke saath (order sequence ke hisaab se) badh raha hai vs ghat raha hai?
with order_reorder_rate as (
	select
		o.user_id,
		o.order_number,
		o.order_id,
		round(avg(opr.reordered), 2) as reorder_rate
	from orders o
	left join order_products_prior opr
	on o.order_id=opr.order_id
	group by o.user_id, o.order_number, o.order_id
),
order_trend as (
	select 
		user_id,
		order_number,
		reorder_rate,
		lag(reorder_rate) over(
			partition by user_id 
			order by order_number asc
		) as previouse_reorder_rate
		from order_reorder_rate
)

select	
	user_id,
	order_number,
	previouse_reorder_rate,
	reorder_rate,
	case 
		when previouse_reorder_rate is null then 'First Order'
		when reorder_rate > previouse_reorder_rate then 'Increasing'
		when reorder_rate < previouse_reorder_rate then 'Decreasing'
		else 'No Change'
	end as trend
from order_trend
order by user_id, order_number;

-- Q. 3- Har customer ka average basket size uske first 5 orders vs baad ke orders mein kaise differ karta hai (naye vs mature customer behavior)?
with basket_size as (
	select
		order_id,
		count(product_id) as basket_size
	from order_products_prior
	group by order_id
),
join_basket_size_orders as (
	select 
		o.order_id,
		o.order_number,
		o.user_id,
		bs.basket_size
	from orders o
	join basket_size bs
	on o.order_id = bs.order_id
)

select
	user_id,
	case 
		when order_number<=5 then 'First 5 '
		else 'Later'
	end as order_phase
	,
	round(avg(basket_size), 2) as avg_basket_size
from join_basket_size_orders
group by user_id, order_phase;

-- Q. 3- Kaunse customers "one-time buyers" hai (sirf 1 order) vs "power users" (top 5% by order count)?
with order_counts as (
	select 
		user_id,
		count(*) as total_orders
	from orders 
	group by user_id
),
customer_rank as (
	select 	
		user_id,
		total_orders,
		ntile(20) over(order by total_orders desc) as bucket
	from order_counts
)

select
	user_id,
	total_orders,
	case 
		when total_orders = 1 then 'One-time Buyers'
		when bucket = 1 then 'Power User'
		else 'Regular'
	end customer_segment
from customer_rank
order by total_orders desc;

-- Customer ka average days_since_prior_order uske engagement tier ke saath correlate karta hai kya?
with customer_tier as (
	select
		user_id,
		total_order_count,
		case 
			when buckets = 1 then 'High'
			when buckets = 2 then 'Medium'
			else 'Low'
		end as segment
	from(
		select
			user_id,
			total_order_count,
			ntile(3) over(order by total_order_count desc) as buckets
		from
		(
			select
				user_id,
				COUNT(*) as total_order_count
			from orders 
			group by user_id
		) as t
	) as x
)

select	
	ct.segment,
	round(avg(o.days_since_prior_order), 2) as avg_days
from customer_tier ct
join orders o
on ct.user_id=o.user_id
group by ct.segment;


-- ================================================
-- Category 2: Product Association / Market Basket
-- ================================================
-- Q. 6- Top 10 product pairs jo sabse zyada saath order kiye jaate hai (self-JOIN + COUNT).
select
	opp1.product_id as product1,
	opp2.product_id as product2,
	count(*) as times_ordered_togather
from order_products_prior opp1
join order_products_prior opp2
on opp1.order_id=opp2.order_id
and opp1.product_id<opp2.product_id
group by opp1.product_id, opp2.product_id
order by times_ordered_togather desc
limit 10;

-- Q. 7- Ek specific high-frequency product (jaise "Banana") ke saath sabse zyada kaunse products order hote hai?
select
	p1.product_name as first_product,
	p2.product_name as second_product,
	count(*) as times_ordered_togather
from order_products_prior opp1
join order_products_prior opp2
on opp1.order_id = opp2.order_id
	and opp1.product_id < opp2.product_id
join products p1
on opp1.product_id = p1.product_id
join products p2
on opp2.product_id = p2.product_id
where p1.product_name = 'banana' or p2.product_name = 'banana'
group by p1.product_name, p2.product_name
order by times_ordered_togather desc
limit 10;

-- Q. 8- Pehli-baar order kiye gaye products (reordered = 0) vs baar-baar order kiye gaye products ki department-wise distribution mein farak hai kya?
WITH order_type AS (
    SELECT
        d.department,
        SUM(CASE WHEN opp.reordered = 0 THEN 1 ELSE 0 END) AS first_time_orders,
        SUM(CASE WHEN opp.reordered = 1 THEN 1 ELSE 0 END) AS repeat_orders,
        COUNT(*) AS total_orders
    FROM order_products_prior opp
    JOIN products p
        ON opp.product_id = p.product_id
    JOIN departments d
        ON p.department_id = d.department_id
    GROUP BY d.department
)

SELECT
    department,
    first_time_orders,
    repeat_orders,
    ROUND((first_time_orders * 100.0 / total_orders), 2) AS first_time_percentage,
    ROUND((repeat_orders * 100.0 / total_orders), 2) AS repeat_percentage
FROM order_type
ORDER BY repeat_percentage DESC;

-- Q. 9- Kaunse products ka "reorder rate" sabse zyada hai — matlab "sticky"/habitual purchase products kaunse hai?
with reordered_count as (
	select 	
		p.product_name,
		sum(opp.reordered) as reordered_count,
		count(*) as total_purchase
	from order_products_prior opp
	join products p
	on opp.product_id = p.product_id
	group by p.product_name
)

select	
	product_name,
	reordered_count,
	total_purchase,
	ROUND(reordered_count * 100.0 / total_purchase, 2) as reordered_rate
from reordered_count
order by reordered_rate desc;

-- Q. 10- Department-level co-occurrence — kya customers same department ke multiple items ek order mein leते hai, ya cross-department shopping karte hai?
with order_department_counts as (
	select
		opp.order_id,
		count(distinct p.department_id) as order_type
	from order_products_prior opp
	join products p
	on opp.product_id = p.product_id
	group by opp.order_id
)
select	
	order_type,
	count(*) as count
from order_department_counts 
group by order_type
order by count desc;

-- =========================================
-- Category 3: Temporal & Sequence Patterns 
-- =========================================
-- Q. 11- Order ke sequence number (ROW_NUMBER() OVER PARTITION BY user_id) ke hisaab se, average basket size kaise change hota hai?
with sequence_number as (
	select	
		o.user_id, 
		o.order_id,
		row_number() over(partition by o.user_id order by o.order_number) as sequence_number,
		count(opp.product_id) as basket_size
	from orders o
	join order_products_prior opp
	on o.order_id=opp.order_id
	group by o.user_id, 
			o.order_id,
			o.order_number
) 
select 	
	sequence_number,
	round(avg(basket_size), 2) as avg_basket_size
from sequence_number 
group by sequence_number;

-- Q. 12- Peak ordering hours department ke hisaab se alag hai kya (jaise Produce morning mein zyada, Snacks evening mein)?
with department_hour_orders as (
	select
		d.department,
		o.order_hour_of_day,
		count(*) as orders
	from orders o
	join order_products_prior opp
	on o.order_id=opp.order_id
	join products p 
	on opp.product_id=p.product_id
	join departments d 
	on p.department_id=d.department_id 
	group by d.department,
			o.order_hour_of_day
),
hour_ranking as (
	select
		department,
		order_hour_of_day,
		orders,
		row_number() over(partition by department order by orders desc) as hour_rnk
	from department_hour_orders
)

select 	
	department,
	order_hour_of_day,
	orders,
	hour_rnk
from hour_ranking
order by department;

-- Q. 13- days_since_prior_order ke buckets (0-7, 8-14, 15-30, 30+) banakar dekhna — kis bucket mein reorder rate sabse zyada hai?
select 		
	case
		when o.days_since_prior_order is null then 'First Order'
		when o.days_since_prior_order > 30 then '30+'
		when o.days_since_prior_order >= 15 then '15-30'
		when o.days_since_prior_order >= 8 then '8-14'
		else '0-7'
	end as buckets,
	count(*) as total_products,
	sum(opp.reordered) as reordered,
	round((sum(opp.reordered)/count(*))*100, 2) as reordered_rate
from orders o
join order_products_prior opp
on o.order_id=opp.order_id
group by buckets;

-- Q. 14- Weekday vs weekend orders mein basket size ya product-mix mein statistically noticeable farak hai kya?
-- Query 1->
with bucket_size as (
	select 
		order_id,
		count(*) as bucket
	from order_products_prior
	group by order_id
)

select 	
	CASE
        WHEN o.order_dow IN (1,2,3,4,5) THEN 'Weekday'
        ELSE 'Weekend'
    END AS day_type,
    count(*) as total_orders,
    round(avg(bs.bucket), 2) as avg_bucket
from basket_size bs
join orders o 
on bs.order_id = o.order_id
group by day_type;

-- Query 2-> 
select
	case 
		when o.order_dow in (1, 2, 3, 4, 5) then 'Weekday'
		else 'Weekend'
	end as type,
	d.department,
	count(*) as total_orders
from orders o
join order_product_prior opp
on o.order_id = opp.order_id
join products p
on opp.product_id = p.product_id
join departments d
on p.department_id = d.department_id
group by type, d.department
order by type, total_orders desc;


-- =========================================
-- Category 4: Ranking & Per-Group Analysis
-- =========================================
--  Q. 15- Har department ke andar top-5 most reordered products (RANK() OVER PARTITION BY department_id).
with dept_wise_reordered_count as (
	select 	
		d.department,
		p.product_name,
		sum(opp.reordered) as reordered_count,
		rank() over(partition by d.department order by sum(opp.reordered) desc) as rnk
	from departments d 
	join products p
	on d.department_id = p.department_id
	join order_products_prior opp
	on p.product_id = opp.product_id
	group by d.department, p.product_name
)

select
	department,
	product_name,
	reordered_count,
	rnk
from dept_wise_reordered_count
where rnk<=5;

-- Q. 16- Har aisle ka contribution % total orders mein — konse aisles "hero" categories hai?
select
	a.aisle,
	count(*) as total_orders,
	round(count(*) * 100.0 /(select count(*) from order_products_prior), 2) as contribution_percentage
from order_products_prior opp
join products p
on opp.product_id = p.product_id
join aisles a 
on p.aisle_id = a.aisle_id
group by a.aisle
order by contribution_percentage desc;

-- Q. 17- Top products jo har order mein sabse pehle cart mein daale jaate hai (add_to_cart_order = 1) — kya ye impulse/staple items hai?
select
	product_name,
	count(add_to_cart_order) as first_item_count
from (
	select	
		opp.order_id,
		p.product_name,
		opp.add_to_cart_order
	from order_products_prior opp
	join products p 
	on opp.product_id = p.product_id
	where opp.add_to_cart_order = 1
) t
group by product_name
order by first_item_count desc
limit 10;

-- Ye products Staple Items hain.

-- Q. 18- Products jinka reorder rate high hai lekin overall order frequency low hai (niche but loyal products) — inhe kaise identify karoge?
select 	
	p.product_name,
	count(*) as total_orders,
	SUM(opp.reordered) AS reordered_count,
	round((sum(opp.reordered)/count(*))*100, 2) as reordered_rate
from order_products_prior opp
join products p
on opp.product_id = p.product_id
group by p.product_name
having count(*) < 1000
	and round((sum(opp.reordered)/count(*))*100, 2) >= 80 
order by 
	reordered_rate desc,
	reordered_count asc;