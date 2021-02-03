select count(*) as total,
count(distinct user_id),
count(distinct product_id),
sum(score),
avg(score),
max(score),
min(score),
stddev(score)
from review

select 
user_id,
count(*) as total_count,
count(distinct product_id) as product_count,
sum(score) as sum,
max(score) as max,
min(score) as min
from review
group by user_id;


select user_id,product_id,score,avg(score) over() as avg_score,
avg(score) over(partition by user_id) as user_avg_score,
score - avg(score) over(partition by user_id) as user_avg_score_diff
from review

select product_id,score,
row_number() over(order by score desc) as row,
rank() over(order by score desc),
dense_rank() over(order by score desc),
lag(product_id) over(order by score desc) as lag1,
lag(product_id,2) over(order by score desc) as lag2,
lead(product_id) over(order by score desc) as lead1,
lead(product_id) over(order by score desc) as lead2
from popular_products
order by row;

select product_id,score,
row_number() over(order by score desc) as row,
sum(score) over(order by score desc rows between unbounded preceding and current row) as cum_score,
avg(score) over(order by score desc rows between 1 preceding and 1 following) as local_avg,
first_value(product_id) over(order by score desc rows between unbounded preceding and unbounded following) as first_value,
last_value(product_id) over(order by score desc rows between unbounded preceding and unbounded following) as last_value
from popular_products
order by row


select product_id,row_number() over(order by score desc) as row,
array_agg(product_id) over(order by score desc rows between unbounded preceding and unbounded following) as whole_agg,
array_agg(product_id) over(order by score desc rows between unbounded preceding and current row) as cum_agg,
array_agg(product_id) over(order by score desc rows between 1 preceding and 1 following) as local_agg
from popular_products
where category='action'
order by row


select *
from (select category,product_id,score,row_number() over(partition by category order by score desc) as rank from popular_products)
as pupolar_products_with_rank
where rank <= 2
order by category,score

select dt,
max(case when indicator='impressions' then val end) as impressions,
max(case when indicator='sessions' then val end) as sessions,
max(case when indicator='users' then val end) as users
from daily_kpi
group by dt
order by dt;

select purchase_id,string_agg(product_id,',') as product_ids,
sum(price) as amount
from purchase_detail_log
group by purchase_id
order by purchase_id

select q.year,
case when p.idx=1 then 'q1'
when p.idx=2 then 'q2'
when p.idx=3 then 'q3'
when p.idx=4 then 'q4'
end as quarter,
case when p.idx=1 then q.q1
when p.idx=2 then q.q2
when p.idx=3 then q.q3
when p.idx=4 then q.q4
end as sales
from quarterly_sales as q
cross join
(select 1 as idx
union all select 2 as idx
union all select 3 as idx
union all select 4 as idx) as p;

select 'app1' as app_name,user_id,name,email from app1_mst_users
union all
select 'app2' as app_name,user_id,name,null as email from app2_mst_users

select m.user_id,m.card_number,count(p.user_id) as purchase_count,
case when m.card_number is not null then 1 else 0 end as has_card,
sign(count(p.user_id)) as has_purchased
from mst_users_with_card_number as m
left join
purchase_log as p
on m.user_id = p.user_id
group by m.user_id,m.card_number
order by user_id

with
mst_devices as (
	select 1 as device_id, 'PC' as device_name
	union all select 2 as device_id, 'SP' as device_name
	union all select 3 as device_id, 'アプリ' as device_name
)
select *
from mst_devices


with
mst_devices(device_id,device_name) as (
	values
	(1,'PC'),
	(2,'SP'),
	(3,'アプリ')
)
select *
from mst_devices

with
series as (
	select generate_series(1,5) as idx
)
select *
from series