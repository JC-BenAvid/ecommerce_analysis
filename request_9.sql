-- ***REQUEST 9***
use mavenfuzzyfactory;

-- Analyzing product launches
select
year(website_sessions.created_at) AS yr,
month(website_sessions.created_at) AS mo,
min(date(website_sessions.created_at)) as month,
count(distinct website_sessions.website_session_id) AS sessions,
count(distinct orders.order_id) AS orders,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) AS cnv_r,
sum(orders.price_usd)/count(distinct website_sessions.website_session_id) AS revenue_per_session,
count(distinct case when primary_product_id = 1 then order_id else null end) AS product_one_orders,
count(distinct case when primary_product_id = 2 then order_id else null end) AS product_two_orders
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2013-04-05' -- date of request
and website_sessions.created_at > '2012-04-01' -- specified in the request
group by 1,2;
-- conclusion: it is hard to get some insight from her, unless a product level analysis is running

-- Product level website pathing
-- step 1: find the relevant /products pageviews with website_session_id
-- step 2: find the next pageview id that occurs after the product pageview
-- step 3: find the pageview_url associated with any applicable next pageview id
-- step 4: summarize the data and analyze the pre vs post periods

-- step 1:
create temporary table products_pageviews
select
website_session_id,
website_pageview_id,
created_at,
case
when created_at < '2013-01-06' then 'A.Pre_product_2'
when created_at >= '2013-01-06' then 'B.Post_product_2'
else 'other and check'
end AS time_period
from website_pageviews
where created_at < '2013-04-06' -- date of request 
and created_at > '2012-10-06' -- star 3 months before product 2, according request
and pageview_url = '/products';

-- step 2: (only for what happened after the products pageview)
create temporary table sessions_w_next_pageview_id
select
products_pageviews.time_period,
products_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) AS min_next_pageview_id
from products_pageviews
left join website_pageviews
on website_pageviews.website_session_id = products_pageviews.website_session_id
and website_pageviews.website_pageview_id > products_pageviews.website_pageview_id
group by 1,2;

-- step 3:
create temporary table sessions_w_next_pageview_url
select
sessions_w_next_pageview_id.time_period,
sessions_w_next_pageview_id.website_session_id,
website_pageviews.pageview_url AS next_pageview_url
from sessions_w_next_pageview_id
left join website_pageviews
on  website_pageviews.website_pageview_id = sessions_w_next_pageview_id.min_next_pageview_id;

-- step 4:
select
time_period,
count(distinct website_session_id) AS sessions,
count(distinct case when next_pageview_url is not null then website_session_id else null end) AS w_next_pg,
count(distinct case when next_pageview_url is not null then website_session_id else null end)/count(distinct website_session_id) AS pct_w_next_pg,
count(distinct case when next_pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end) AS to_mrfuzzy,
count(distinct case when next_pageview_url = '/the-original-mr-fuzzy' then website_session_id else null end)/count(distinct website_session_id) AS pct_to_mrfuzzy,
count(distinct case when next_pageview_url = '/the-forever-love-bear' then website_session_id else null end) AS to_lovebear,
count(distinct case when next_pageview_url = '/the-forever-love-bear' then website_session_id else null end)/count(distinct website_session_id) AS pct_to_lovebear
from sessions_w_next_pageview_url
group by time_period;

