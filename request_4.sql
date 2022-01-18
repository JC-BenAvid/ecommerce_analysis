-- ***REQUEST 4***
use mavenfuzzyfactory;


-- Landing page Trend Analysis
-- break this problem into 4 steps:
-- STEP 1: find the first website_pageview_id for relevant sessions
-- STEP 2: identify the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing by week (bounce rate, sessions to each lander)

-- step 1
create temporary table sessions_w_min_pv_id_and_view_count
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pageview_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM
    website_sessions
        LEFT JOIN
    website_pageviews ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at > '2012-06-01' -- date of requested analysis
        AND website_sessions.created_at < '2012-08-31' -- request date
        AND website_sessions.utm_source = 'gsearch'
        AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY website_sessions.website_session_id;

-- step 2
create temporary table sessions_w_counts_lander_and_created_at
SELECT 
    sessions_w_min_pv_id_and_view_count.website_session_id,
    sessions_w_min_pv_id_and_view_count.first_pageview_id,
    sessions_w_min_pv_id_and_view_count.count_pageviews,
    website_pageviews.pageview_url AS landing_page,
    website_pageviews.created_at AS session_created_at
FROM
    sessions_w_min_pv_id_and_view_count
        LEFT JOIN
    website_pageviews ON sessions_w_min_pv_id_and_view_count.first_pageview_id = website_pageviews.website_pageview_id;

-- step 3 and step 4
select
yearweek(session_created_at) as year_week,
min(date(session_created_at)) as week_start_date,
count(distinct website_session_id) as total_sessions,
count(distinct case when count_pageviews = 1 then website_session_id else null end) as bounced_sessions,
count(distinct case when count_pageviews = 1 then website_session_id else null end)*1/count(distinct website_session_id) as bounce_rate,
count(distinct case when landing_page = '/home' then website_session_id else null end) as home_sessions,
count(distinct case when landing_page = '/lander-1' then website_session_id else null end) as lander_sessions
from sessions_w_counts_lander_and_created_at
group by yearweek(session_created_at);

