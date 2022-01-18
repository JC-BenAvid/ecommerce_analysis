-- Initial exploration
use mavenfuzzyfactory;

select * from orders
where order_id between 1000 and 1010; -- arbitrary

select * from order_items
where order_item_id between 1000 and 1010;-- arbitrary

select * from website_pageviews
where website_pageview_id between 1000 and 1010;-- arbitrary

select * from website_sessions
where website_session_id between 1000 and 1010;-- arbitrary