-- ***REQUEST 5***
use mavenfuzzyfactory;

-- CONVERSION FUNNEL
-- break this problem into 4 steps:
-- STEP 1: select all pageviews for relevant sessions
-- STEP 2: identify each relevant pageviews as the specific funnel step
-- STEP 3: create the session-level conversion funnel view
-- STEP 4: aggregate the data to assess funnel performance

-- step 1:
select
website_sessions.website_session_id,
website_pageviews.pageview_url,
-- website_pageviews.created_at AS pageview_created_at,
case when pageview_url = '/products' then 1 else 0 end AS products_page,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end AS mrfuzzy_page,
case when pageview_url = '/cart' then 1 else 0 end AS cart_page,
case when pageview_url = '/shipping' then 1 else 0 end AS shipping_page,
case when pageview_url = '/billing' then 1 else 0 end AS billing_page,
case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end AS thankyou_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where 
website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
and website_sessions.created_at > '2012-08-05' -- dictated by requestor
and website_sessions.created_at < '2012-09-05' -- request date
-- and website_pageviews.pageview_url in ('/lander-2','/products','/the-original-mr-fuzzy','/cart')
order by website_sessions.website_session_id, website_pageviews.created_at;

-- step 2:
-- next step: use the last code into a subquery
select
website_session_id,
max(products_page) AS product_made_it,
max(mrfuzzy_page) AS mrfuzzy_made_it,
max(cart_page) AS cart_made_it,
max(shipping_page) AS shipping_made_it,
max(billing_page) AS billing_made_it,
max(thankyou_page) AS thankyou_made_it
from (
select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at AS pageview_created_at,
case when pageview_url = '/products' then 1 else 0 end AS products_page,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end AS mrfuzzy_page,
case when pageview_url = '/cart' then 1 else 0 end AS cart_page,
case when pageview_url = '/shipping' then 1 else 0 end AS shipping_page,
case when pageview_url = '/billing' then 1 else 0 end AS billing_page,
case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end AS thankyou_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where
website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
and website_sessions.created_at > '2012-08-05'
and website_sessions.created_at < '2012-09-05'
order by website_sessions.website_session_id, website_pageviews.created_at) AS pageview_level
group by website_session_id;

-- step 3:
-- now convert last query into a temporary table
create temporary table session_level_made_it_flags
select
website_session_id,
max(products_page) AS product_made_it,
max(mrfuzzy_page) AS mrfuzzy_made_it,
max(cart_page) AS cart_made_it,
max(shipping_page) AS shipping_made_it,
max(billing_page) AS billing_made_it,
max(thankyou_page) AS thankyou_made_it
from (
select website_sessions.website_session_id,
website_pageviews.pageview_url,
website_pageviews.created_at AS pageview_created_at,
case when pageview_url = '/products' then 1 else 0 end AS products_page,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end AS mrfuzzy_page,
case when pageview_url = '/cart' then 1 else 0 end AS cart_page,
case when pageview_url = '/shipping' then 1 else 0 end AS shipping_page,
case when pageview_url = '/billing' then 1 else 0 end AS billing_page,
case when pageview_url = '/thank-you-for-your-order' then 1 else 0 end AS thankyou_page
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where
website_sessions.utm_source = 'gsearch'
and website_sessions.utm_campaign = 'nonbrand'
and website_sessions.created_at > '2012-08-05'
and website_sessions.created_at < '2012-09-05'
order by website_sessions.website_session_id, website_pageviews.created_at) AS pageview_level
group by website_session_id;

select * from session_level_made_it_flags;

-- step 4:
-- final output (part 1)
select
count(distinct website_session_id) AS sessions,
sum(product_made_it) AS to_products,
sum(mrfuzzy_made_it) AS to_mrfuzzy,
sum(cart_made_it) AS to_cart,
sum(shipping_made_it) AS to_shipping,
sum(billing_made_it) AS to_billing,
sum(thankyou_made_it) AS to_thankyou
from session_level_made_it_flags;

-- final output, clicks rate  (part 2)
select
count(distinct website_session_id) AS sessions,
sum(product_made_it)/count(distinct website_session_id) AS lander_rt,
sum(mrfuzzy_made_it)/sum(product_made_it) AS product_rt,
sum(cart_made_it)/sum(mrfuzzy_made_it) AS mrfuzzy_rt,
sum(shipping_made_it)/sum(cart_made_it) AS cart_rt,
sum(billing_made_it)/sum(shipping_made_it) AS shipping_rt,
sum(thankyou_made_it)/sum(billing_made_it) AS billing_rt
from session_level_made_it_flags;


