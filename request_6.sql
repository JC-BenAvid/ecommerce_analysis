-- ***REQUEST 6***
use mavenfuzzyfactory;

-- comparing channel characteristics, and lookig for mobile device
select
utm_source,
count(distinct website_sessions. website_session_id) AS sessions,
count(distinct case when device_type = 'mobile' then website_session_id else null end) AS mobile_sessions,
count(distinct case when device_type = 'mobile' then website_session_id else null end)/
	count(distinct website_sessions. website_session_id) AS pct_mobile
from website_sessions
where created_at > '2012-08-22' -- specified by requestor
and created_at < '2012-11-30' -- request date
and utm_campaign = 'nonbrand' -- limiting to nonbrand paid search
group by utm_source;

-- cross channel bid optimization
select
website_sessions.device_type,
website_sessions.utm_source,
count(distinct website_sessions.website_session_id) AS sessions,
count(distinct orders.order_id) AS orders,
count(distinct orders.order_id)/count(distinct website_sessions.website_session_id) AS cvRate
from website_sessions
left join orders
on orders.website_session_id = website_sessions.website_session_id
where website_sessions.created_at > '2012-08-22' -- specified in the request
and website_sessions.created_at < '2012-11-30' -- request date
and website_sessions.utm_campaign = 'nonbrand' -- limiting to nonbrand paid search according request
group by
website_sessions.device_type,
website_sessions.utm_source;