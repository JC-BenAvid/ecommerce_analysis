-- ***REQUEST 8***
use mavenfuzzyfactory;

-- Analyzing seasonality
-- step 1a looking for the usage hours
select
date(created_at) AS created_date,
weekday(created_at) AS wkday,
hour(created_at) AS hr,
count(distinct website_session_id) as sessions
from website_sessions
where created_at between '2012-09-15' and '2012-11-15' -- according request
group by 1,2,3;

-- step 1b summarizing last result
select
hr,
-- round(avg(sessions),1) AS avg_sessions,
round(avg(case when wkday = 0 then sessions else null end),1) AS mo,
round(avg(case when wkday = 1 then sessions else null end),1) AS tue,
round(avg(case when wkday = 2 then sessions else null end),1) AS wed,
round(avg(case when wkday = 3 then sessions else null end),1) AS thu,
round(avg(case when wkday = 4 then sessions else null end),1) AS fri,
round(avg(case when wkday = 5 then sessions else null end),1) AS sat,
round(avg(case when wkday = 6 then sessions else null end),1) AS sun
from(
select
date(created_at) AS created_date,
weekday(created_at) AS wkday,
hour(created_at) AS hr,
count(distinct website_session_id) as sessions
from website_sessions
where created_at between '2012-09-15' and '2012-11-15' -- according request
group by 1,2,3
) AS daily_hourly_sessions
group by 1
order by 1;