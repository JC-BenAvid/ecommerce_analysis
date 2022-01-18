-- ***REQUEST 2***
use mavenfuzzyfactory;

-- Traffic Source Trending (volume by week), after bid down gsearch
SELECT 
    MIN(DATE(created_at)) AS week_started_at,
    COUNT(DISTINCT website_session_id) AS sessions
FROM
    website_sessions
WHERE
    created_at < '2012-05-10' -- request date
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand' -- traffic source of interest
GROUP BY YEAR(created_at) , WEEK(created_at);

