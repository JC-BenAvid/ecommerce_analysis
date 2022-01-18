-- ***REQUEST 7***
use mavenfuzzyfactory;

-- Analyzing channel portfolio trends 
select
min(date(created_at)) AS week_start_date,
count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) AS g_dtop_sessions,
count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end) AS b_dtop_sessions,
count(distinct case when utm_source = 'bsearch' and device_type = 'desktop' then website_session_id else null end)/
count(distinct case when utm_source = 'gsearch' and device_type = 'desktop' then website_session_id else null end) AS b_pct_of_g_dtop,
min(date(created_at)) AS week_start_date,
count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) AS g_mob_sessions,
count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end) AS b_mob_sessions,
count(distinct case when utm_source = 'bsearch' and device_type = 'mobile' then website_session_id else null end)/
count(distinct case when utm_source = 'gsearch' and device_type = 'mobile' then website_session_id else null end) AS b_pct_of_g_mob
from
website_sessions
where created_at > '2012-11-04' -- specified in the request
and created_at < '2012-12-22' -- defined by request date
and utm_campaign = 'nonbrand'
group by yearweek(created_at);


