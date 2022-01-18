-- ***REQUEST 3***
use mavenfuzzyfactory;

-- Analyzing Landing Pages - A/B test
-- break this problem into 4 steps plus step 0:
-- STEP 0: find out when the new page/lander launched
-- STEP 1: find the first website_pageview_id for relevant sessions
-- STEP 2: identify the landing page of each session
-- STEP 3: counting pageviews for each session, to identify "bounces"
-- STEP 4: summarizing total sessions and bounce sessions, by Landing Page

-- step 0: find out when the new page/lander launched
SELECT 
    MIN(created_at) AS first_created_at,
    MIN(website_pageview_id) AS first_pageview_id
FROM
    website_pageviews
WHERE
    pageview_url = '/lander-1'
        AND created_at IS NOT NULL;
-- from this we get: 2012-06-19 01:35:54 and 23504 session

-- step 1: find the first website_pageview_id for relevant sessions
create temporary table first_test_pageview
SELECT 
    website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pageview_id
FROM
    website_pageviews
        INNER JOIN
    website_sessions ON website_sessions.website_session_id = website_pageviews.website_session_id
        AND website_sessions.created_at < '2012-07-28'
        AND website_pageviews.website_pageview_id > 23504
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY website_pageviews.website_session_id;

-- drop table first_test_pageview;

-- step 2: identify the landing page of each session
create temporary table nonbrand_test_session_w_home_landing_page
SELECT 
    first_test_pageview.website_session_id,
    website_pageviews.pageview_url AS landing_page
FROM
    first_test_pageview
        LEFT JOIN
    website_pageviews ON website_pageviews.website_pageview_id = first_test_pageview.min_pageview_id
WHERE
    website_pageviews.pageview_url IN ('/home' , '/lander-1');

-- step 3: counting pageviews for each session, to identify "bounces"
create temporary table nonbrand_test_bounced_sessions
SELECT 
    nonbrand_test_session_w_home_landing_page.website_session_id,
    nonbrand_test_session_w_home_landing_page.landing_page,
    COUNT(website_pageviews.website_pageview_id) AS N_pv_per_session
FROM
    nonbrand_test_session_w_home_landing_page
        LEFT JOIN
    website_pageviews ON website_pageviews.website_session_id = nonbrand_test_session_w_home_landing_page.website_session_id
GROUP BY nonbrand_test_session_w_home_landing_page.website_session_id , nonbrand_test_session_w_home_landing_page.landing_page
HAVING COUNT(website_pageviews.website_pageview_id) = 1;

-- step 4: summarizing total sessions and bounce sessions, by Landing Page
SELECT 
    nonbrand_test_session_w_home_landing_page.landing_page,
    COUNT(DISTINCT nonbrand_test_session_w_home_landing_page.website_session_id) AS total_sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT nonbrand_test_bounced_sessions.website_session_id) / COUNT(DISTINCT nonbrand_test_session_w_home_landing_page.website_session_id) AS bounce_rate
FROM
    nonbrand_test_session_w_home_landing_page
        LEFT JOIN
    nonbrand_test_bounced_sessions ON nonbrand_test_session_w_home_landing_page.website_session_id = nonbrand_test_bounced_sessions.website_session_id
GROUP BY nonbrand_test_session_w_home_landing_page.landing_page;
